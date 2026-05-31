"""VAD filter — FireRedVAD with RMS energy fallback."""
import numpy as np


def filter_silence(
    audio_np: np.ndarray, sr: int = 16000, threshold: float = 0.5
) -> list[tuple[int, int]]:
    """Return list of (start_sample, end_sample) for active segments."""
    try:
        from fireredvad import FireRedVad
        vad = FireRedVad()
        # FireRedVAD expects int16 or float32 mono
        segments = []
        frame_ms = 30
        frame_samples = int(sr * frame_ms / 1000)
        active_start = None
        for i in range(0, len(audio_np) - frame_samples + 1, frame_samples):
            frame = audio_np[i : i + frame_samples]
            is_speech = vad.is_speech(frame, sr)
            if is_speech and active_start is None:
                active_start = i
            elif not is_speech and active_start is not None:
                segments.append((active_start, i))
                active_start = None
        if active_start is not None:
            segments.append((active_start, len(audio_np)))
        return segments if segments else [(0, len(audio_np))]
    except Exception:
        return _rms_vad(audio_np, threshold)


def _rms_vad(
    audio_np: np.ndarray, threshold: float, frame_size: int = 512, hop: int = 256
) -> list[tuple[int, int]]:
    """Simple RMS energy-based VAD fallback."""
    n_frames = max(1, (len(audio_np) - frame_size) // hop + 1)
    rms = np.array([
        np.sqrt(np.mean(audio_np[i * hop : i * hop + frame_size] ** 2))
        for i in range(n_frames)
    ])
    max_rms = rms.max() if rms.max() > 0 else 1.0
    # Use lower threshold (0.1) to avoid filtering out quiet sounds like breathing
    active = rms > 0.1 * max_rms

    segments = []
    start = None
    for i, a in enumerate(active):
        if a and start is None:
            start = i * hop
        elif not a and start is not None:
            segments.append((start, i * hop))
            start = None
    if start is not None:
        segments.append((start, len(audio_np)))

    # Merge segments closer than 0.5s to avoid tiny fragments
    if segments:
        sr = 16000
        merged = [segments[0]]
        for s, e in segments[1:]:
            if s - merged[-1][1] < int(0.5 * sr):
                merged[-1] = (merged[-1][0], e)
            else:
                merged.append((s, e))
        segments = merged

    return segments if segments else [(0, len(audio_np))]
