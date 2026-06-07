"""FCM alert dispatcher — sends push notifications or mocks when no credentials."""

import json
import logging
import os
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)
_ALERTS_LOG = Path(__file__).parent.parent / "storage" / "alerts_log.json"


def _log_alert(user_id: str, rule_id: str, template_id: str, success: bool, device_token: str):
    _ALERTS_LOG.parent.mkdir(parents=True, exist_ok=True)
    entries = []
    if _ALERTS_LOG.exists():
        try:
            entries = json.loads(_ALERTS_LOG.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, ValueError):
            entries = []
    entries.append({
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "user_id": user_id,
        "rule_id": rule_id,
        "template_id": template_id,
        "success": success,
        "device_token_prefix": device_token[:8] if device_token else "",
    })
    _ALERTS_LOG.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")


def send_alert(user_id: str, device_token: str, alert: dict) -> bool:
    """Send FCM push notification. Falls back to mock mode if no credentials."""
    cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")

    if not cred_path:
        logger.info("[MOCK FCM] user=%s rule=%s title=%s", user_id, alert["rule_id"], alert["title"])
        _log_alert(user_id, alert["rule_id"], alert["template_id"], True, device_token)
        return True

    try:
        import firebase_admin  # noqa: F401
        from firebase_admin import credentials, messaging

        if not firebase_admin._apps:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)

        message = messaging.Message(
            notification=messaging.Notification(title=alert["title"], body=alert["body"]),
            data={"deeplink": alert.get("deeplink", ""), "rule_id": alert["rule_id"]},
            token=device_token,
        )
        messaging.send(message)
        _log_alert(user_id, alert["rule_id"], alert["template_id"], True, device_token)
        return True
    except Exception as e:
        logger.error("FCM send failed: %s", e)
        _log_alert(user_id, alert["rule_id"], alert["template_id"], False, device_token)
        return False
