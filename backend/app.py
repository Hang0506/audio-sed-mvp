"""Audio SED MVP — FastAPI backend."""

import tempfile
from pathlib import Path

import librosa
from fastapi import FastAPI, HTTPException, UploadFile
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from yamnet_inference import analyze, load_model
from cough_recommendation import (
    CoughAssessment, classify_and_recommend,
    COUGH_TYPES, DURATION_CATEGORIES, SUBJECT_GROUPS, RED_FLAG_LABELS,
)
from cough_type_v2 import classify_cough_type

STORAGE_DIR = Path(__file__).parent / "storage" / "real_wav"
RECORDINGS_DIR = Path(__file__).parent / "storage" / "recordings"
FRONTEND_DIR = Path(__file__).parent.parent / "frontend"

app = FastAPI()


@app.on_event("startup")
def startup():
    STORAGE_DIR.mkdir(parents=True, exist_ok=True)
    RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)
    load_model()


@app.get("/api/samples")
def list_samples():
    return sorted(f.name for f in STORAGE_DIR.glob("*.wav"))


@app.get("/api/samples/{filename}")
def get_sample(filename: str):
    if ".." in filename or "/" in filename or "\\" in filename:
        raise HTTPException(400, "Invalid filename")
    path = STORAGE_DIR / filename
    if not path.is_file():
        raise HTTPException(404, "File not found")
    return FileResponse(path, media_type="audio/wav")


@app.post("/api/analyze")
async def analyze_audio(file: UploadFile, mode: str = "v1"):
    tmp_path = None
    try:
        data = await file.read()
        ext = Path(file.filename or "audio.wav").suffix or ".wav"
        with tempfile.NamedTemporaryFile(suffix=ext, delete=False) as tmp:
            tmp.write(data)
            tmp_path = Path(tmp.name)
        # Save recording for debugging
        from datetime import datetime
        save_name = datetime.now().strftime("%Y%m%d_%H%M%S") + ext
        (RECORDINGS_DIR / save_name).write_bytes(data)
        audio_np, sr = librosa.load(str(tmp_path), sr=16000, mono=True)
        result = analyze(audio_np, sr)
        # V2: add cough type classification if cough detected
        if mode == "v2" and result["has_cough"]:
            result["cough_type_analysis"] = classify_cough_type(audio_np, sr)
        return result
    except Exception as e:
        raise HTTPException(400, str(e))
    finally:
        if tmp_path and tmp_path.exists():
            tmp_path.unlink()


# --- Cough Classification & Recommendation ---

class AssessmentInput(BaseModel):
    cough_type: str = "dry"
    duration: str = "acute"
    subject: str = "adult"
    red_flags: list[str] = []
    night_cough: bool = False
    post_flu: bool = False
    cough_frequency: str = "moderate"
    # From audio analysis (optional, frontend passes these)
    audio_has_cough: bool = True
    audio_cough_count: int = 1
    audio_confidence: float = 0.5


@app.get("/api/recommendation/options")
def get_recommendation_options():
    """Return all options for the assessment form."""
    return {
        "cough_types": COUGH_TYPES,
        "durations": DURATION_CATEGORIES,
        "subjects": SUBJECT_GROUPS,
        "red_flags": RED_FLAG_LABELS,
    }


@app.post("/api/recommendation")
def get_recommendation(input: AssessmentInput):
    """Classify cough and return recommendations."""
    assessment = CoughAssessment(
        cough_type=input.cough_type,
        duration=input.duration,
        subject=input.subject,
        red_flags=input.red_flags,
        night_cough=input.night_cough,
        post_flu=input.post_flu,
        cough_frequency=input.cough_frequency,
    )
    return classify_and_recommend(
        assessment,
        audio_has_cough=input.audio_has_cough,
        audio_cough_count=input.audio_cough_count,
        audio_confidence=input.audio_confidence,
    )


# Static files mounted last so /api/* routes take priority
if FRONTEND_DIR.is_dir():
    app.mount("/", StaticFiles(directory=str(FRONTEND_DIR), html=True), name="frontend")
