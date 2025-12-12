"""Database models for Community Challenge & Social Work Hub module."""
from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Numeric, String, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ..database import Base


def default_uuid():
    return uuid4()


class ChallengeStatus(str, Enum):
    """Challenge status enumeration."""
    ACTIVE = "active"
    COMPLETED = "completed"
    EXPIRED = "expired"
    CANCELLED = "cancelled"


class ChallengeCategory(str, Enum):
    """Challenge category enumeration."""
    SOCIAL = "social"
    HEALTH = "health"
    EDUCATION = "education"
    ENVIRONMENTAL = "environmental"
    SECURITY = "security"
    RELIGIOUS = "religious"
    INFRASTRUCTURE = "infrastructure"
    ECONOMIC = "economic"


class ParticipationRole(str, Enum):
    """Participation role enumeration."""
    PARTICIPANT = "participant"
    VOLUNTEER = "volunteer"
    DONOR = "donor"
    ORGANIZER = "organizer"


class SupportType(str, Enum):
    """Stakeholder support type enumeration."""
    ENDORSEMENT = "endorsement"
    DONATION = "donation"
    MANPOWER = "manpower"
    EXPERTISE = "expertise"
    MATERIALS = "materials"


class CommunityChallenge(Base):
    """Community Challenge model."""
    __tablename__ = "community_challenges"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    creator_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[ChallengeCategory] = mapped_column(SQLEnum(ChallengeCategory), nullable=False)
    
    # Geo-location
    latitude: Mapped[float] = mapped_column(Numeric(10, 7), nullable=False)
    longitude: Mapped[float] = mapped_column(Numeric(10, 7), nullable=False)
    county: Mapped[Optional[str]] = mapped_column(String(100))
    district: Mapped[Optional[str]] = mapped_column(String(100))
    
    # Challenge details
    needed_resources: Mapped[dict] = mapped_column(JSONB, default=dict)  # {funds: amount, volunteers: count, supplies: []}
    urgency_level: Mapped[str] = mapped_column(String(20), default="medium")  # low, medium, high, critical
    duration_days: Mapped[Optional[int]] = mapped_column(Integer)
    expected_impact: Mapped[Optional[str]] = mapped_column(Text)
    
    # Status and tracking
    status: Mapped[ChallengeStatus] = mapped_column(SQLEnum(ChallengeStatus), default=ChallengeStatus.ACTIVE)
    progress_percentage: Mapped[float] = mapped_column(Numeric(5, 2), default=0.0)
    
    # Media
    media_urls: Mapped[list[str]] = mapped_column(JSONB, default=list)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime)
    
    # Relationships
    creator: Mapped["User"] = relationship("User", foreign_keys=[creator_id])
    participations: Mapped[list["ChallengeParticipation"]] = relationship(back_populates="challenge", cascade="all, delete-orphan")
    progress_updates: Mapped[list["ChallengeProgress"]] = relationship(back_populates="challenge", cascade="all, delete-orphan")
    stakeholder_supports: Mapped[list["StakeholderSupport"]] = relationship(back_populates="challenge", cascade="all, delete-orphan")
    notifications: Mapped[list["Notification"]] = relationship("Notification", foreign_keys="Notification.challenge_id", back_populates="challenge")


class ChallengeParticipation(Base):
    """User participation in a challenge."""
    __tablename__ = "challenge_participations"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    user_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    challenge_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("community_challenges.id"), nullable=False)
    role: Mapped[ParticipationRole] = mapped_column(SQLEnum(ParticipationRole), nullable=False)
    contribution_details: Mapped[dict] = mapped_column(JSONB, default=dict)  # {amount, hours, supplies, etc.}
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user: Mapped["User"] = relationship("User", foreign_keys=[user_id])
    challenge: Mapped["CommunityChallenge"] = relationship(back_populates="participations")


class ChallengeProgress(Base):
    """Progress updates for a challenge."""
    __tablename__ = "challenge_progress"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    challenge_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("community_challenges.id"), nullable=False)
    user_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    media_urls: Mapped[list[str]] = mapped_column(JSONB, default=list)
    progress_percentage: Mapped[float] = mapped_column(Numeric(5, 2), nullable=False)
    milestone: Mapped[Optional[str]] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    challenge: Mapped["CommunityChallenge"] = relationship(back_populates="progress_updates")
    user: Mapped["User"] = relationship("User", foreign_keys=[user_id])


class StakeholderSupport(Base):
    """Stakeholder (NGO, government, etc.) support for challenges."""
    __tablename__ = "stakeholder_supports"

    id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), primary_key=True, default=default_uuid)
    stakeholder_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    challenge_id: Mapped[uuid4] = mapped_column(UUID(as_uuid=True), ForeignKey("community_challenges.id"), nullable=False)
    support_type: Mapped[SupportType] = mapped_column(SQLEnum(SupportType), nullable=False)
    details: Mapped[dict] = mapped_column(JSONB, default=dict)  # {amount, volunteers_count, materials, etc.}
    is_high_priority: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    stakeholder: Mapped["User"] = relationship("User", foreign_keys=[stakeholder_id])
    challenge: Mapped["CommunityChallenge"] = relationship(back_populates="stakeholder_supports")
