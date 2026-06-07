"""Telegram Ops — push food images to Ops team for manual labeling."""

import logging
import os
from datetime import datetime

import httpx

logger = logging.getLogger(__name__)

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "")


async def push_to_telegram(image_bytes: bytes, user_id: str, caption: str = "") -> bool:
    """Send food image to Ops Telegram group for human labeling.

    Returns True on success or when in mock mode (no token configured).
    """
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    full_caption = (
        f"🍽️ Food Detection Request\n"
        f"User: {user_id}\n"
        f"Time: {timestamp}\n"
        f"Note: {caption}\n"
        f"→ Vui lòng gán nhãn thực phẩm trong ảnh."
    )

    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        logger.info("[MOCK] push_to_telegram user=%s caption=%s", user_id, full_caption)
        return True

    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendPhoto"
    try:
        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.post(
                url,
                data={"chat_id": TELEGRAM_CHAT_ID, "caption": full_caption},
                files={"photo": ("food.jpg", image_bytes, "image/jpeg")},
            )
        if resp.status_code == 200:
            return True
        logger.warning("Telegram API error %s: %s", resp.status_code, resp.text)
        return False
    except Exception as e:
        logger.error("Telegram push failed: %s", e)
        return False
