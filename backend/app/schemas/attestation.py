"""Schemas for community attestation."""
from __future__ import annotations

from pydantic import BaseModel, Field


class AttestationRequest(BaseModel):
    """Request to attest to a report."""
    action: str = Field(..., description="Action: 'confirm', 'deny', or 'needs_info'")
    confidence: str | None = Field(
        default=None,
        description="Confidence level: 'high', 'medium', or 'low'",
    )
    comment: str | None = Field(default=None, description="Optional comment")
    latitude: float | None = Field(
        default=None,
        description="User's current latitude for distance calculation",
    )
    longitude: float | None = Field(
        default=None,
        description="User's current longitude for distance calculation",
    )


class AttestationResponse(BaseModel):
    """Response after creating an attestation."""
    id: str
    report_id: str
    action: str
    distance_km: float | None
    message: str


class NotificationResponse(BaseModel):
    """Notification for user."""
    id: str
    report_id: str | None = None  # Optional for challenge notifications
    challenge_id: str | None = None  # Optional for challenge notifications
    title: str
    message: str
    read: bool
    action_taken: bool
    created_at: str
    report_summary: str | None = None
    report_category: str | None = None
    report_severity: str | None = None
