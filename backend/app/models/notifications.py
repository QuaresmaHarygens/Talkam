"""Notification models for community attestation."""
from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Numeric, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base


def default_uuid():
    return uuid4()


class Notification(Base):
    """Notification sent to community members for report attestation."""
    __tablename__ = "notifications"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    notification_type: Mapped[str] = mapped_column(String(32), default="attestation_request")
    title: Mapped[str] = mapped_column(String(255))
    message: Mapped[str] = mapped_column(Text())
    read: Mapped[bool] = mapped_column(Boolean, default=False)
    action_taken: Mapped[bool] = mapped_column(Boolean, default=False)  # Whether user attested
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    # Relationships
    user: Mapped[Optional["User"]] = relationship(back_populates="notifications")
    report: Mapped["Report"] = relationship(back_populates="notifications")


class Attestation(Base):
    """Community member attestation to a report."""
    __tablename__ = "attestations"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    anonymous_token_id: Mapped[Optional[uuid4]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("anonymous_tokens.id"), nullable=True
    )
    action: Mapped[str] = mapped_column(String(32))  # 'confirm', 'deny', 'needs_info'
    confidence: Mapped[Optional[str]] = mapped_column(String(16), nullable=True)  # 'high', 'medium', 'low'
    comment: Mapped[Optional[str]] = mapped_column(Text(), nullable=True)
    distance_km: Mapped[Optional[float]] = mapped_column(Float, nullable=True)  # Distance from report location
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    report: Mapped["Report"] = relationship(back_populates="attestations")
    user: Mapped[Optional["User"]] = relationship(back_populates="attestations")
