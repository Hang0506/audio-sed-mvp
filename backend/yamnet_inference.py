"""YAMNet ONNX inference for respiratory sound event detection."""
import time
from pathlib import Path

import numpy as np
import onnxruntime as ort

from vad_filter import filter_silence

TARGET_CLASSES = {36: "Breathing", 37: "Wheeze", 38: "Snoring", 42: "Cough"}
CLASS_VI = {36: "Thở", 37: "Thở khò khè", 38: "Ngáy", 42: "Ho"}
CONFIDENCE_THRESHOLD = 0.65
COUGH_THRESHOLD = 0.30
WINDOW_SEC = 0.96
HOP_SEC = 0.48

from typing import Optional

_session: Optional[ort.InferenceSession] = None


def load_model() -> ort.InferenceSession:
    """Load YAMNet ONNX model (singleton)."""
    global _session
    if _session is None:
        model_path = Path(__file__).parent / "models" / "yamnet.onnx"
        _session = ort.InferenceSession(
            str(model_path), providers=["CPUExecutionProvider"]
        )
    return _session


def analyze(audio_np: np.ndarray, sr: int = 16000) -> dict:
    """Run YAMNet inference on audio, return detected events."""
    t0 = time.perf_counter()
    session = load_model()
    input_name = session.get_inputs()[0].name
    window_samples = int(WINDOW_SEC * sr)
    hop_samples = int(HOP_SEC * sr)

    segments = filter_silence(audio_np, sr)
    events: list[dict] = []

    for seg_start, seg_end in segments:
        # Expand short segments from original audio instead of zero-padding
        if seg_end - seg_start < window_samples:
            center = (seg_start + seg_end) // 2
            seg_start = max(0, center - window_samples // 2)
            seg_end = min(len(audio_np), seg_start + window_samples)
            seg_start = max(0, seg_end - window_samples)
        seg = audio_np[seg_start:seg_end].astype(np.float32)
        if len(seg) < window_samples:
            seg = np.pad(seg, (0, window_samples - len(seg)))

        for w_start in range(0, len(seg) - window_samples + 1, hop_samples):
            window = seg[w_start : w_start + window_samples]
            outputs = session.run(None, {input_name: window})
            scores = outputs[0]  # [num_frames, 521]
            mean_scores = scores.mean(axis=0) if scores.ndim == 2 else scores.flatten()

            abs_start = seg_start + w_start
            for idx, class_name in TARGET_CLASSES.items():
                threshold = COUGH_THRESHOLD if idx == 42 else CONFIDENCE_THRESHOLD
                if idx < len(mean_scores) and mean_scores[idx] >= threshold:
                    events.append({
                        "start": abs_start / sr,
                        "end": (abs_start + window_samples) / sr,
                        "class": class_name,
                        "class_vi": CLASS_VI[idx],
                        "confidence": float(mean_scores[idx]),
                    })

    events = _merge_events(events)
    inference_time_ms = (time.perf_counter() - t0) * 1000
    return {
        "events": events,
        "has_cough": any(e["class"] == "Cough" for e in events),
        "inference_time_ms": round(inference_time_ms, 1),
        "duration_sec": round(len(audio_np) / sr, 2),
    }


def _merge_events(events: list[dict]) -> list[dict]:
    """Merge overlapping events of the same class."""
    if not events:
        return []
    by_class: dict[str, list[dict]] = {}
    for e in events:
        by_class.setdefault(e["class"], []).append(e)

    merged = []
    for cls, evts in by_class.items():
        evts.sort(key=lambda x: x["start"])
        cur = evts[0].copy()
        for nxt in evts[1:]:
            if nxt["start"] <= cur["end"]:
                cur["end"] = max(cur["end"], nxt["end"])
                cur["confidence"] = max(cur["confidence"], nxt["confidence"])
            else:
                merged.append(cur)
                cur = nxt.copy()
        merged.append(cur)
    merged.sort(key=lambda x: x["start"])
    return merged
