"""V2 Cough Type Classifier — Dry/Wet classification using MFCC + Dense network.

Model source: brilboy/Cough-Sound-Classification (Kaggle cough-sound dataset)
Architecture: 40 MFCC -> Dense(100) -> Dense(200) -> Dense(100) -> Dense(2) softmax
Inference: pure numpy (no TensorFlow needed at runtime)
"""
import time
from pathlib import Path

import librosa
import numpy as np

from typing import Optional

_weights: Optional[dict] = None
LABELS = ["dry", "wet"]
LABELS_VI = {"dry": "Ho khan", "wet": "Ho có đờm"}


def _load_weights():
    global _weights
    if _weights is None:
        path = Path(__file__).parent / "models" / "cough_type_weights.npz"
        data = np.load(str(path))
        _weights = {
            "w0": data["w0"], "b0": data["b0"],
            "w1": data["w1"], "b1": data["b1"],
            "w2": data["w2"], "b2": data["b2"],
            "w3": data["w3"], "b3": data["b3"],
        }
    return _weights


def _relu(x):
    return np.maximum(0, x)


def _softmax(x):
    e = np.exp(x - np.max(x, axis=-1, keepdims=True))
    return e / e.sum(axis=-1, keepdims=True)


def _forward(x: np.ndarray) -> np.ndarray:
    """Forward pass through the dense network."""
    w = _load_weights()
    x = _relu(x @ w["w0"] + w["b0"])
    x = _relu(x @ w["w1"] + w["b1"])
    x = _relu(x @ w["w2"] + w["b2"])
    x = _softmax(x @ w["w3"] + w["b3"])
    return x


def extract_mfcc(audio_np: np.ndarray, sr: int = 16000) -> np.ndarray:
    """Extract 40 MFCC features (mean across time)."""
    mfccs = librosa.feature.mfcc(y=audio_np, sr=sr, n_mfcc=40)
    return np.mean(mfccs.T, axis=0)


def classify_cough_type(audio_np: np.ndarray, sr: int = 16000) -> dict:
    """Classify cough audio as dry or wet.
    
    Returns:
        dict with keys: cough_type, cough_type_vi, confidence, probabilities, inference_time_ms
    """
    t0 = time.perf_counter()
    _load_weights()

    features = extract_mfcc(audio_np, sr)
    probs = _forward(features.reshape(1, -1))[0]

    idx = int(np.argmax(probs))
    cough_type = LABELS[idx]
    inference_ms = (time.perf_counter() - t0) * 1000

    return {
        "cough_type": cough_type,
        "cough_type_vi": LABELS_VI[cough_type],
        "confidence": round(float(probs[idx]), 3),
        "probabilities": {"dry": round(float(probs[0]), 3), "wet": round(float(probs[1]), 3)},
        "inference_time_ms": round(inference_ms, 1),
    }
