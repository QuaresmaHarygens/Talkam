"""Device token models for push notifications."""
from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base


def default_uuid():
    return uuid4()


class DeviceToken(Base):
    """Device token for push notifications (FCM/APNs)."""
    __tablename__ = "device_tokens"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    anonymous_token_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("anonymous_tokens.id", ondelete="CASCADE"), nullable=True)
    token: Mapped[str] = mapped_column(String(512), unique=True)  # FCM or APNs token
    platform: Mapped[str] = mapped_column(String(16))  # 'android', 'ios', 'web'
    app_version: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    device_info: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)  # Device model, OS version
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user: Mapped[Optional["User"]] = relationship(back_populates="device_tokens")
