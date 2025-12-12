"""Pydantic schemas for Community Challenge module."""
from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from ..models.challenges import ChallengeCategory, ChallengeStatus, ParticipationRole, SupportType


class ChallengeCreateRequest(BaseModel):
    """Request schema for creating a challenge."""
    title: str = Field(..., min_length=5, max_length=255)
    description: str = Field(..., min_length=20)
    category: ChallengeCategory
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    county: Optional[str] = None
    district: Optional[str] = None
    needed_resources: dict = Field(default_factory=dict)  # {funds: amount, volunteers: count, supplies: []}
    urgency_level: str = Field(default="medium", pattern="^(low|medium|high|critical)$")
    duration_days: Optional[int] = Field(None, gt=0)
    expected_impact: Optional[str] = None
    media_urls: list[str] = Field(default_factory=list)


class ChallengeResponse(BaseModel):
    """Response schema for challenge details."""
    id: UUID
    creator_id: UUID
    title: str
    description: str
    category: ChallengeCategory
    latitude: float
    longitude: float
    county: Optional[str]
    district: Optional[str]
    needed_resources: dict
    urgency_level: str
    duration_days: Optional[int]
    expected_impact: Optional[str]
    status: ChallengeStatus
    progress_percentage: float
    media_urls: list[str]
    created_at: datetime
    updated_at: datetime
    expires_at: Optional[datetime]
    
    # Computed fields
    creator_name: Optional[str] = None
    participants_count: int = 0
    volunteers_count: int = 0
    donors_count: int = 0
    
    class Config:
        from_attributes = True


class ChallengeListResponse(BaseModel):
    """Response schema for challenge list."""
    challenges: list[ChallengeResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


class ParticipationRequest(BaseModel):
    """Request schema for joining a challenge."""
    role: ParticipationRole
    contribution_details: dict = Field(default_factory=dict)


class ParticipationResponse(BaseModel):
    """Response schema for participation."""
    id: UUID
    user_id: UUID
    challenge_id: UUID
    role: ParticipationRole
    contribution_details: dict
    created_at: datetime
    user_name: Optional[str] = None
    
    class Config:
        from_attributes = True


class ProgressUpdateRequest(BaseModel):
    """Request schema for progress update."""
    description: str = Field(..., min_length=10)
    media_urls: list[str] = Field(default_factory=list)
    progress_percentage: float = Field(..., ge=0, le=100)
    milestone: Optional[str] = None


class ProgressUpdateResponse(BaseModel):
    """Response schema for progress update."""
    id: UUID
    challenge_id: UUID
    user_id: UUID
    description: str
    media_urls: list[str]
    progress_percentage: float
    milestone: Optional[str]
    created_at: datetime
    user_name: Optional[str] = None
    
    class Config:
        from_attributes = True


class StakeholderSupportRequest(BaseModel):
    """Request schema for stakeholder support."""
    support_type: SupportType
    details: dict = Field(default_factory=dict)  # {amount, volunteers_count, materials, etc.}
    is_high_priority: bool = False


class StakeholderSupportResponse(BaseModel):
    """Response schema for stakeholder support."""
    id: UUID
    stakeholder_id: UUID
    challenge_id: UUID
    support_type: SupportType
    details: dict
    is_high_priority: bool
    created_at: datetime
    stakeholder_name: Optional[str] = None
    
    class Config:
        from_attributes = True
