from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base


def default_uuid():
    return uuid4()


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    full_name: Mapped[str] = mapped_column(String(255))
    phone: Mapped[Optional[str]] = mapped_column(String(32), unique=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(32), default="citizen")
    verified: Mapped[bool] = mapped_column(Boolean, default=False)
    language: Mapped[str] = mapped_column(String(8), default="en-LR")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    reports: Mapped[list["Report"]] = relationship(back_populates="user")
    comments: Mapped[list["Comment"]] = relationship(back_populates="user")
    notifications: Mapped[list["Notification"]] = relationship(back_populates="user")
    attestations: Mapped[list["Attestation"]] = relationship(back_populates="user")
    device_tokens: Mapped[list["DeviceToken"]] = relationship(back_populates="user")
    created_challenges: Mapped[list["CommunityChallenge"]] = relationship("CommunityChallenge", foreign_keys="CommunityChallenge.creator_id", back_populates="creator")
    challenge_participations: Mapped[list["ChallengeParticipation"]] = relationship("ChallengeParticipation", foreign_keys="ChallengeParticipation.user_id", back_populates="user")
    challenge_progress: Mapped[list["ChallengeProgress"]] = relationship("ChallengeProgress", foreign_keys="ChallengeProgress.user_id", back_populates="user")
    stakeholder_supports: Mapped[list["StakeholderSupport"]] = relationship("StakeholderSupport", foreign_keys="StakeholderSupport.stakeholder_id", back_populates="stakeholder")


class AnonymousToken(Base):
    __tablename__ = "anonymous_tokens"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    device_hash: Mapped[str] = mapped_column(String(255))
    token: Mapped[str] = mapped_column(String(255))
    expires_at: Mapped[datetime]
    county: Mapped[Optional[str]]
    capabilities: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    reports: Mapped[list["Report"]] = relationship(back_populates="anonymous_token")


class Location(Base):
    __tablename__ = "locations"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    latitude: Mapped[float]
    longitude: Mapped[float]
    county: Mapped[str]
    district: Mapped[Optional[str]]
    description: Mapped[Optional[str]]

    reports: Mapped[list["Report"]] = relationship(back_populates="location")


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[Optional[str]] = mapped_column(String(20), unique=True, nullable=True)  # RPT-YYYY-XXXXXX
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    anonymous_token_id: Mapped[Optional[uuid4]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("anonymous_tokens.id")
    )
    location_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("locations.id"))
    category: Mapped[str] = mapped_column(String(64))
    severity: Mapped[str] = mapped_column(String(16))
    summary: Mapped[str] = mapped_column(String(280))
    details: Mapped[Optional[str]] = mapped_column(Text())
    status: Mapped[str] = mapped_column(String(32), default="submitted")
    anonymous: Mapped[bool] = mapped_column(Boolean, default=False)
    witness_count: Mapped[int] = mapped_column(Integer, default=0)
    ai_severity_score: Mapped[Optional[float]] = mapped_column(Numeric(asdecimal=False), nullable=True)
    # New AI and priority fields
    priority_score: Mapped[Optional[float]] = mapped_column(Numeric(3, 2), nullable=True)  # 0.00-1.00
    ai_category: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    recommended_agency: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    is_likely_fake: Mapped[bool] = mapped_column(Boolean, default=False)
    fake_confidence: Mapped[Optional[float]] = mapped_column(Numeric(3, 2), nullable=True)
    legal_advice_snapshot: Mapped[Optional[str]] = mapped_column(Text(), nullable=True)
    hash_anchored_on_chain: Mapped[Optional[str]] = mapped_column(Text(), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user: Mapped[Optional[User]] = relationship(back_populates="reports")
    anonymous_token: Mapped[Optional[AnonymousToken]] = relationship(back_populates="reports")
    location: Mapped[Optional[Location]] = relationship(back_populates="reports")
    media: Mapped[list["ReportMedia"]] = relationship(back_populates="report", cascade="all, delete-orphan")
    verifications: Mapped[list["Verification"]] = relationship(back_populates="report", cascade="all, delete-orphan")
    comments: Mapped[list["Comment"]] = relationship(back_populates="report", cascade="all, delete-orphan")
    flags: Mapped[list["Flag"]] = relationship(back_populates="report", cascade="all, delete-orphan")
    notifications: Mapped[list["Notification"]] = relationship(back_populates="report", cascade="all, delete-orphan")
    attestations: Mapped[list["Attestation"]] = relationship(back_populates="report", cascade="all, delete-orphan")


class ReportMedia(Base):
    __tablename__ = "report_media"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    media_key: Mapped[str] = mapped_column(String(255))
    media_type: Mapped[str] = mapped_column(String(16))
    checksum: Mapped[Optional[str]] = mapped_column(String(128))
    hash_sha256: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)  # SHA256 hash for tamper-evidence
    # Use non-reserved attribute name while keeping column name as "metadata"
    metadata_json: Mapped[Optional[dict]] = mapped_column("metadata", JSONB, nullable=True)  # EXIF and other metadata
    blurred: Mapped[bool] = mapped_column(Boolean, default=True)
    voice_masked: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    report: Mapped[Report] = relationship(back_populates="media")


class Verification(Base):
    __tablename__ = "verifications"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    action: Mapped[str] = mapped_column(String(32))
    notes: Mapped[Optional[str]] = mapped_column(Text())
    confidence: Mapped[Optional[float]] = mapped_column(Numeric(asdecimal=False))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    report: Mapped[Report] = relationship(back_populates="verifications")


class Comment(Base):
    __tablename__ = "comments"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    user_id: Mapped[Optional[uuid4]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    visibility: Mapped[str] = mapped_column(String(32), default="reporter")
    body: Mapped[str] = mapped_column(Text())
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    report: Mapped[Report] = relationship(back_populates="comments")
    user: Mapped[Optional[User]] = relationship(back_populates="comments")


class Flag(Base):
    __tablename__ = "flags"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    report_id: Mapped[uuid4] = mapped_column(
        UUID(as_uuid=True), ForeignKey("reports.id", ondelete="CASCADE")
    )
    reason: Mapped[str] = mapped_column(String(128))
    status: Mapped[str] = mapped_column(String(32), default="open")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    report: Mapped[Report] = relationship(back_populates="flags")


class NGO(Base):
    __tablename__ = "ngos"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    name: Mapped[str] = mapped_column(String(255))
    contact_email: Mapped[Optional[str]]
    phone: Mapped[Optional[str]]
    focus: Mapped[Optional[dict]] = mapped_column(JSONB)
    verified: Mapped[bool] = mapped_column(Boolean, default=False)
    counties: Mapped[Optional[dict]] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
