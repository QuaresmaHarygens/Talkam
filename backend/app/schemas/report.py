from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from .common import Location, MediaRef, ReportSummary, TimelineEvent


class ReportCreateRequest(BaseModel):
    category: str = Field(..., description="Report category")
    severity: str = Field(..., description="Severity level")
    anonymous: bool | None = False
    summary: str
    details: str | None = None
    media: list[MediaRef] = []
    location: Location
    witness_count: int | None = None
    offline_reference: str | None = None
    sms_reference: str | None = None


class ReportResponse(BaseModel):
    id: UUID
    report_id: str | None = None  # Public report ID (RPT-YYYY-XXXXXX)
    status: str
    created_at: datetime
    updated_at: datetime | None = None
    summary: str
    details: str | None = None
    category: str
    severity: str
    location: Location
    verification_score: float | None = None
    assigned_agency: str | None = None
    media: list[MediaRef] = []
    timeline: list[TimelineEvent] = []


class VerificationRequest(BaseModel):
    action: str
    comment: str | None = None
    witness_count: int | None = None


class CommentRequest(BaseModel):
    body: str
    visibility: str = "reporter"


class SearchResponse(BaseModel):
    results: list[ReportSummary]
    total: int = 0
    page: int = 1
    page_size: int = 50
    total_pages: int = 0


class ReportAssignmentRequest(BaseModel):
    agency: str = Field(..., description="Agency or NGO name/identifier the report is assigned to")
    status: str | None = Field(default="assigned", description="Optional status to set when assigning")
    note: str | None = Field(default=None, description="Optional note about the assignment")


class ReportStatusUpdateRequest(BaseModel):
    status: str = Field(..., description="New status for the report")
    note: str | None = Field(default=None, description="Optional note about the status change")
