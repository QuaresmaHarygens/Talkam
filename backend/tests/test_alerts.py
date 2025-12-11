import asyncio

from app.schemas.alerts import AlertRequest
from app.services.alerts import AlertDispatcher
from app.config import get_settings


def test_alert_dispatcher_returns_counts():
    dispatcher = AlertDispatcher(get_settings())
    payload = AlertRequest(title="Test", message="Hello", severity="info", counties=["Montserrado"], sms_fallback=["+231700000000"])
    result = asyncio.run(dispatcher.broadcast(payload.model_dump()))
    assert result["delivered_push"] >= 100
    assert result["delivered_sms"] >= 50
