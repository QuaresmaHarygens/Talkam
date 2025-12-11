from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Header, status
from pydantic import BaseModel

from app.config import Settings, get_settings
from app.models.core import Location, Report
from app.schemas.report import ReportCreateRequest
from sqlalchemy.ext.asyncio import AsyncSession

from .deps import get_db_session
from .reports import create_report

router = APIRouter(prefix="/sms", tags=["sms"])


class SMSWebhook(BaseModel):
    from_number: str
    message: str
    timestamp: str | None = None


@router.post("/ingest")
async def ingest_sms_report(
    body: SMSWebhook,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
    x_sms_token: str | None = Header(default=None, alias="X-SMS-Token"),
) -> dict[str, str]:
    """Ingest report submitted via SMS gateway."""
    if x_sms_token != settings.sms_gateway_token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid SMS gateway token")
    # Parse SMS message (format: "CAT=category;LOC=county;MSG=summary")
    parts = body.message.split(";")
    category = "general"
    county = "Montserrado"
    summary = body.message
    for part in parts:
        if "=" in part:
            key, value = part.split("=", 1)
            if key.strip().upper() == "CAT":
                category = value.strip()
            elif key.strip().upper() == "LOC":
                county = value.strip()
            elif key.strip().upper() == "MSG":
                summary = value.strip()
    # Create anonymous report (simplified - in production, create anonymous token first)
    from app.models.core import Location, Report
    
    location = Location(latitude=0.0, longitude=0.0, county=county)
    session.add(location)
    await session.flush()
    
    report = Report(
        user_id=None,
        location_id=location.id,
        category=category,
        severity="medium",
        summary=summary,
        anonymous=True,
    )
    session.add(report)
    await session.commit()
    return {"status": "queued", "report_id": str(report.id), "message": "SMS report ingested"}
