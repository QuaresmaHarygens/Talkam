from __future__ import annotations

from typing import List

from pydantic import BaseModel, Field


class AlertRequest(BaseModel):
    title: str
    message: str
    severity: str = Field(pattern="^(info|warning|critical)$", default="info")
    counties: List[str]
    channels: List[str] = Field(default_factory=lambda: ["push", "sms"])
    sms_fallback: List[str] = []
