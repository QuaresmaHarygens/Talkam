from __future__ import annotations

from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, Field


class Location(BaseModel):
    latitude: float
    longitude: float
    county: str
    district: str | None = None
    description: str | None = None


class MediaRef(BaseModel):
    key: str
    type: Annotated[str, Field(pattern="^(photo|video|audio)$")]
    checksum: str | None = None
    blur_faces: bool | None = None
    voice_masked: bool | None = None


class TimelineEvent(BaseModel):
    at: datetime
    action: str
    actor: str | None = None
    notes: str | None = None


class ReportSummary(BaseModel):
    id: UUID
    summary: str
    category: str
    county: str | None
    severity: str
    status: str
