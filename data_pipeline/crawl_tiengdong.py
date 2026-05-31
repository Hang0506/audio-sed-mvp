"""Crawl tiengdong.com for audio files, fallback to synthetic generation."""
import os
import sys
import struct
import wave
from pathlib import Path

import numpy as np
import requests
from bs4 import BeautifulSoup

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "backend" / "storage" / "raw"
WAV_DIR = BASE_DIR / "backend" / "storage" / "real_wav"
RAW_DIR.mkdir(parents=True, exist_ok=True)
WAV_DIR.mkdir(parents=True, exist_ok=True)

SEARCH_TERMS = ["tiếng ho", "tiếng thở", "tiếng ngáy"]
HEADERS = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
SR = 16000


def crawl_mp3s():
    """Try to crawl .mp3 links from tiengdong.com."""
    mp3_urls = []
    for term in SEARCH_TERMS:
        try:
            url = f"https://tiengdong.com/?s={requests.utils.quote(term)}"
            print(f"[CRAWL] Searching: {url}")
            resp = requests.get(url, headers=HEADERS, timeout=10)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "html.parser")
            # Look for .mp3 links in audio tags, a[href], source[src]
            for tag in soup.find_all(["a", "source", "audio"]):
                href = tag.get("href") or tag.get("src") or ""
                if ".mp3" in href:
                    mp3_urls.append(href)
            # Also search for links on detail pages
            for link in soup.find_all("a", href=True):
                if "/tieng-" in link["href"] or "/sound" in link["href"]:
                    try:
                        detail = requests.get(link["href"], headers=HEADERS, timeout=10)
                        dsoup = BeautifulSoup(detail.text, "html.parser")
                        for t in dsoup.find_all(["a", "source", "audio"]):
                            h = t.get("href") or t.get("src") or ""
                            if ".mp3" in h:
                                mp3_urls.append(h)
                    except Exception:
                        continue
        except Exception as e:
            print(f"[CRAWL] Failed for '{term}': {e}")
    return list(set(mp3_urls))


def download_and_convert(mp3_urls):
    """Download mp3s and convert to 16kHz mono wav."""
    converted = 0
    for i, url in enumerate(mp3_urls):
        try:
            if not url.startswith("http"):
                url = "https://tiengdong.com" + url
            print(f"[DL] ({i+1}/{len(mp3_urls)}) {url}")
            resp = requests.get(url, headers=HEADERS, timeout=30)
            resp.raise_for_status()
            fname = f"audio_{i+1:02d}.mp3"
            mp3_path = RAW_DIR / fname
            mp3_path.write_bytes(resp.content)
            # Convert with pydub
            from pydub import AudioSegment
            audio = AudioSegment.from_mp3(str(mp3_path))
            audio = audio.set_frame_rate(SR).set_channels(1)
            wav_path = WAV_DIR / fname.replace(".mp3", ".wav")
            audio.export(str(wav_path), format="wav")
            converted += 1
            print(f"  -> {wav_path.name}")
        except Exception as e:
            print(f"  [ERR] {e}")
    return converted


def generate_synthetic():
    """Generate >=10 synthetic wav files as fallback."""
    print("[FALLBACK] Generating synthetic audio files...")
    rng = np.random.default_rng(42)
    specs = [
        ("cough", 4, [(300, 0.3), (600, 0.2)]),
        ("breathing", 5, [(150, 0.4), (250, 0.3)]),
        ("snoring", 6, [(80, 0.5), (160, 0.3)]),
    ]
    count = 0
    for label, base_dur, freqs in specs:
        for idx in range(1, 5):  # 4 each = 12 total
            dur = base_dur + rng.uniform(-1, 2)
            n = int(SR * dur)
            t = np.linspace(0, dur, n, dtype=np.float32)
            signal = np.zeros(n, dtype=np.float32)
            for freq, amp in freqs:
                f = freq * (1 + 0.1 * rng.standard_normal())
                signal += amp * np.sin(2 * np.pi * f * t).astype(np.float32)
            # Add noise + envelope
            signal += 0.05 * rng.standard_normal(n).astype(np.float32)
            env = np.ones(n, dtype=np.float32)
            fade = min(int(0.1 * SR), n // 4)
            env[:fade] = np.linspace(0, 1, fade)
            env[-fade:] = np.linspace(1, 0, fade)
            signal *= env
            # Normalize to [-1, 1]
            peak = np.max(np.abs(signal))
            if peak > 0:
                signal /= peak
            # Write as 16-bit PCM wav
            wav_path = WAV_DIR / f"{label}_{idx:02d}.wav"
            with wave.open(str(wav_path), "w") as wf:
                wf.setnchannels(1)
                wf.setsampwidth(2)
                wf.setframerate(SR)
                pcm = (signal * 32767).astype(np.int16)
                wf.writeframes(pcm.tobytes())
            count += 1
            print(f"  -> {wav_path.name} ({dur:.1f}s)")
    print(f"[FALLBACK] Generated {count} synthetic wav files.")
    return count


def main():
    print("=" * 50)
    print("Audio Crawler — tiengdong.com + fallback")
    print("=" * 50)
    mp3_urls = crawl_mp3s()
    converted = 0
    if mp3_urls:
        print(f"\n[INFO] Found {len(mp3_urls)} .mp3 URLs. Downloading...")
        converted = download_and_convert(mp3_urls)
    if converted < 10:
        print(f"\n[INFO] Only {converted} wav files from crawl. Using fallback.")
        generate_synthetic()
    # Final count
    wavs = list(WAV_DIR.glob("*.wav"))
    print(f"\n[DONE] {len(wavs)} .wav files in {WAV_DIR}")


if __name__ == "__main__":
    main()
