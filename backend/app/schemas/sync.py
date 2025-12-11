from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from .report import ReportCreateRequest


class SyncRequest(BaseModel):
    offline_references: list[str] = []
    since: datetime | None = None


class SyncResponse(BaseModel):
    synced_reports: list[UUID]
    pending_count: int
