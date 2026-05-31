"""Download YAMNet ONNX model files from HuggingFace."""
import os
import requests
from pathlib import Path

BASE_URL = "https://huggingface.co/jafet21/yamnetonnx/resolve/main"
MODELS_DIR = Path(__file__).parent / "models"
FILES = {
    "yamnet.onnx": {"min_size": 5_000_000},
    "yamnet_class_map.csv": {"min_size": 1000},
}


def download_file(filename: str, min_size: int):
    dest = MODELS_DIR / filename
    if dest.exists() and dest.stat().st_size >= min_size:
        print(f"[SKIP] {filename} already exists ({dest.stat().st_size:,} bytes)")
        return
    url = f"{BASE_URL}/{filename}"
    print(f"[DOWNLOAD] {filename} from {url}")
    resp = requests.get(url, stream=True)
    resp.raise_for_status()
    total = int(resp.headers.get("content-length", 0))
    downloaded = 0
    with open(dest, "wb") as f:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):
            f.write(chunk)
            downloaded += len(chunk)
            if total:
                print(f"  {downloaded / total * 100:.1f}% ({downloaded:,}/{total:,})", end="\r")
    print(f"\n[DONE] {filename} ({downloaded:,} bytes)")


if __name__ == "__main__":
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    for name, opts in FILES.items():
        download_file(name, opts["min_size"])
