"""Schemas for device token management."""
from __future__ import annotations

from pydantic import BaseModel, Field


class DeviceTokenRegisterRequest(BaseModel):
    """Request to register a device token."""
    token: str = Field(..., description="FCM or APNs device token", min_length=1, max_length=512)
    platform: str = Field(..., description="Platform: 'android', 'ios', or 'web'")
    app_version: str | None = Field(default=None, description="App version")
    device_info: str | None = Field(default=None, description="Device model and OS version")


class DeviceTokenResponse(BaseModel):
    """Response for device token operations."""
    id: str
    platform: str
    active: bool
    created_at: str
    last_used_at: str | None = None


class DeviceTokenListResponse(BaseModel):
    """List of device tokens."""
    tokens: list[DeviceTokenResponse]
    total: int
