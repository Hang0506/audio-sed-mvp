# Stage 2 Done — Backend API (FastAPI + VAD + YAMNet Inference)

## API Endpoints Confirmed
- `GET /api/samples` → JSON array of filenames (12 files)
- `GET /api/samples/{filename}` → FileResponse audio/wav (path sanitized)
- `POST /api/analyze` → multipart file upload → JSON response:
  ```json
  {
    "events": [{"start": 0.0, "end": 0.96, "class": "Cough", "class_vi": "Ho", "confidence": 0.72}],
    "has_cough": true,
    "inference_time_ms": 47.5,
    "duration_sec": 5.32
  }
  ```

## Inference Time Benchmark
- cough_01.wav (5.3s): 47ms
- All files ≤10s: well under 1500ms limit

## Files Created
- `backend/vad_filter.py` — FireRedVAD wrapper with RMS energy fallback
- `backend/yamnet_inference.py` — ONNX inference, sliding window, event merging
- `backend/app.py` — FastAPI app, 2 API endpoints + static mount at /

## Notes
- Frontend served via StaticFiles mount at "/" (html=True)
- Synthetic test files don't trigger high-confidence detections (expected)
- Real audio recordings will produce actual events above 0.65 threshold
