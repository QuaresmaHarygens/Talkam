from __future__ import annotations

from datetime import datetime
from typing import Any

from app.config import Settings


class AlertDispatcher:
    """Simple dispatcher stub for push + SMS alerts."""

    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    async def broadcast(self, payload: dict[str, Any]) -> dict[str, Any]:
        # In production, integrate with FCM/APNs and SMS gateways.
        return {
            "delivered_push": len(payload.get("counties", [])) * 100,
            "delivered_sms": len(payload.get("sms_fallback", [])) * 50,
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
