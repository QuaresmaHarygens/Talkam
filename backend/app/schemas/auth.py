from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    full_name: str
    phone: str | None = None
    email: EmailStr | None = None
    password: str = Field(min_length=8)
    language: str = "en-LR"


class LoginRequest(BaseModel):
    phone: str
    password: str
    device_id: str | None = None


class AuthTokens(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int
    roles: list[str]


class AnonymousStartRequest(BaseModel):
    device_hash: str
    county: str | None = None
    capabilities: list[str] = []


class AnonymousStartResponse(BaseModel):
    token: str
    expires_in: int
    offline_queue_limit: int = 50


class ForgotPasswordRequest(BaseModel):
    phone: str | None = None
    email: EmailStr | None = None


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str = Field(min_length=8)


class PasswordResetResponse(BaseModel):
    message: str
    expires_in: int | None = None


class TokenPayload(BaseModel):
    sub: str
    exp: datetime
    scopes: list[str]

    @classmethod
    def from_subject(cls, subject: str, scopes: list[str], ttl_minutes: int) -> "TokenPayload":
        return cls(sub=subject, exp=datetime.utcnow() + timedelta(minutes=ttl_minutes), scopes=scopes)

    def to_claims(self) -> dict[str, Any]:
        return {"sub": self.sub, "exp": int(self.exp.timestamp()), "scopes": self.scopes}
