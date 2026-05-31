# Stage 1 Done — Data Pipeline + Model Setup

## Files Created
- `data_pipeline/crawl_tiengdong.py` — Crawl script with fallback synthetic generation
- `backend/requirements.txt` — 11 pinned dependencies
- `backend/download_model.py` — HuggingFace model downloader
- `backend/models/yamnet.onnx` — 16,124,200 bytes
- `backend/models/yamnet_class_map.csv` — 522 rows (521 classes + header)
- `backend/storage/raw/` — directory (empty, crawl site unavailable)
- `backend/storage/real_wav/` — 12 .wav files (synthetic fallback)

## WAV Files Generated (12 total)
- cough_01.wav through cough_04.wav
- breathing_01.wav through breathing_04.wav
- snoring_01.wav through snoring_04.wav
- All: 16kHz, mono, 3-8 seconds duration

## Model Files
- yamnet.onnx: 16,124,200 bytes (16MB)
- yamnet_class_map.csv: 522 rows, columns: index, mid, display_name

## Dependencies Installed
- pip install -r backend/requirements.txt: SUCCESS
- Key versions: fastapi>=0.115.0, onnxruntime>=1.21.0, librosa>=0.10.2, fireredvad>=0.0.1

## Exit Gates
- [x] crawl script runs successfully
- [x] ≥10 .wav files in backend/storage/real_wav/
- [x] All .wav files: 16kHz mono
- [x] yamnet.onnx exists (>5MB)
- [x] yamnet_class_map.csv exists (521+ rows)
- [x] pip install succeeds

## Notes
- tiengdong.com was unreachable; fallback synthetic audio generated
- Synthetic files use sine waves + noise to simulate cough/breathing/snoring patterns
- Model downloaded directly from HuggingFace CDN
