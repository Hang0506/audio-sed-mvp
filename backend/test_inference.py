"""Quick test: run inference on real wav files."""
from yamnet_inference import load_model, analyze
import librosa
from pathlib import Path

load_model()
wav_dir = Path("storage/real_wav")
targets = ["audio_08.wav", "audio_100.wav", "audio_02.wav", "audio_103.wav", "audio_03.wav"]
files = [wav_dir / f for f in targets if (wav_dir / f).exists()]
if not files:
    files = sorted(wav_dir.glob("*.wav"))[:10]

for wav in files:
    audio, sr = librosa.load(str(wav), sr=16000, mono=True)
    result = analyze(audio, sr)
    events = result["events"]
    ev_str = ", ".join(f'{e["class"]}({e["confidence"]:.2f})' for e in events[:3])
    if not ev_str:
        ev_str = "(none detected)"
    print(f'{wav.name:20s} | {result["duration_sec"]}s | {result["inference_time_ms"]:.0f}ms | cough={result["has_cough"]} | {ev_str}')
