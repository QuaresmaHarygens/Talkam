"""API endpoints for Community Challenge & Social Work Hub module."""
from __future__ import annotations

from datetime import datetime, timedelta
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..models.challenges import (
    ChallengeCategory,
    ChallengeParticipation,
    ChallengeProgress,
    ChallengeStatus,
    CommunityChallenge,
    ParticipationRole,
    StakeholderSupport,
    SupportType,
)
from ..schemas.challenge import (
    ChallengeCreateRequest,
    ChallengeListResponse,
    ChallengeResponse,
    ParticipationRequest,
    ParticipationResponse,
    ProgressUpdateRequest,
    ProgressUpdateResponse,
    StakeholderSupportRequest,
    StakeholderSupportResponse,
)
from ..services.geo_clustering import get_challenges_in_radius, get_challenges_count_in_radius
from ..services.challenge_notifications import (
    notify_challenge_created,
    notify_challenge_progress,
    notify_volunteer_request,
    notify_stakeholder_support,
)
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/challenges", tags=["challenges"])


@router.post("/create", response_model=ChallengeResponse, status_code=status.HTTP_201_CREATED)
async def create_challenge(
    body: ChallengeCreateRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ChallengeResponse:
    """Create a new community challenge."""
    # Calculate expiration date if duration is provided
    expires_at = None
    if body.duration_days:
        expires_at = datetime.utcnow() + timedelta(days=body.duration_days)
    
    challenge = CommunityChallenge(
        creator_id=user.id,
        title=body.title,
        description=body.description,
        category=body.category,
        latitude=body.latitude,
        longitude=body.longitude,
        county=body.county,
        district=body.district,
        needed_resources=body.needed_resources,
        urgency_level=body.urgency_level,
        duration_days=body.duration_days,
        expected_impact=body.expected_impact,
        media_urls=body.media_urls,
        expires_at=expires_at,
    )
    
    session.add(challenge)
    await session.flush()
    
    # Create initial participation record for creator
    participation = ChallengeParticipation(
        user_id=user.id,
        challenge_id=challenge.id,
        role=ParticipationRole.ORGANIZER,
        contribution_details={},
    )
    session.add(participation)
    await session.commit()
    await session.refresh(challenge)
    
    # Notify nearby users about new challenge
    try:
        await notify_challenge_created(session, challenge, radius_km=5.0)
    except Exception as e:
        import logging
        logging.warning(f"Failed to send challenge creation notifications: {e}")
    
    return ChallengeResponse(
        id=challenge.id,
        creator_id=challenge.creator_id,
        title=challenge.title,
        description=challenge.description,
        category=challenge.category,
        latitude=float(challenge.latitude),
        longitude=float(challenge.longitude),
        county=challenge.county,
        district=challenge.district,
        needed_resources=challenge.needed_resources,
        urgency_level=challenge.urgency_level,
        duration_days=challenge.duration_days,
        expected_impact=challenge.expected_impact,
        status=challenge.status,
        progress_percentage=float(challenge.progress_percentage),
        media_urls=challenge.media_urls,
        created_at=challenge.created_at,
        updated_at=challenge.updated_at,
        expires_at=challenge.expires_at,
        creator_name=user.full_name,
        participants_count=1,
        volunteers_count=0,
        donors_count=0,
    )


@router.get("/list", response_model=ChallengeListResponse)
async def list_challenges(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    latitude: float = Query(..., description="User's latitude"),
    longitude: float = Query(..., description="User's longitude"),
    radius_km: float = Query(5.0, ge=0.1, le=50.0, description="Search radius in kilometers"),
    category: Optional[str] = Query(None, description="Filter by category"),
    status: Optional[str] = Query("active", description="Filter by status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
) -> ChallengeListResponse:
    """Get list of challenges within radius, with geo-clustering."""
    offset = (page - 1) * page_size
    
    challenges = await get_challenges_in_radius(
        session=session,
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        category=category,
        status=status,
        limit=page_size,
        offset=offset,
    )
    
    total = await get_challenges_count_in_radius(
        session=session,
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        category=category,
        status=status,
    )
    
    # Load relationships and compute counts
    challenge_responses = []
    for challenge in challenges:
        # Get participation counts
        participation_stmt = select(ChallengeParticipation).where(
            ChallengeParticipation.challenge_id == challenge.id
        )
        participation_result = await session.execute(participation_stmt)
        participations = participation_result.scalars().all()
        
        participants_count = len(participations)
        volunteers_count = sum(1 for p in participations if p.role == ParticipationRole.VOLUNTEER)
        donors_count = sum(1 for p in participations if p.role == ParticipationRole.DONOR)
        
        challenge_responses.append(
            ChallengeResponse(
                id=challenge.id,
                creator_id=challenge.creator_id,
                title=challenge.title,
                description=challenge.description,
                category=challenge.category,
                latitude=float(challenge.latitude),
                longitude=float(challenge.longitude),
                county=challenge.county,
                district=challenge.district,
                needed_resources=challenge.needed_resources,
                urgency_level=challenge.urgency_level,
                duration_days=challenge.duration_days,
                expected_impact=challenge.expected_impact,
                status=challenge.status,
                progress_percentage=float(challenge.progress_percentage),
                media_urls=challenge.media_urls,
                created_at=challenge.created_at,
                updated_at=challenge.updated_at,
                expires_at=challenge.expires_at,
                creator_name=challenge.creator.full_name if challenge.creator else None,
                participants_count=participants_count,
                volunteers_count=volunteers_count,
                donors_count=donors_count,
            )
        )
    
    return ChallengeListResponse(
        challenges=challenge_responses,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size if total > 0 else 0,
    )


@router.get("/{challenge_id}", response_model=ChallengeResponse)
async def get_challenge(
    challenge_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ChallengeResponse:
    """Get challenge details by ID."""
    stmt = (
        select(CommunityChallenge)
        .where(CommunityChallenge.id == challenge_id)
        .options(selectinload(CommunityChallenge.creator))
    )
    result = await session.execute(stmt)
    challenge = result.scalar_one_or_none()
    
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    # Get participation counts
    participation_stmt = select(ChallengeParticipation).where(
        ChallengeParticipation.challenge_id == challenge.id
    )
    participation_result = await session.execute(participation_stmt)
    participations = participation_result.scalars().all()
    
    participants_count = len(participations)
    volunteers_count = sum(1 for p in participations if p.role == ParticipationRole.VOLUNTEER)
    donors_count = sum(1 for p in participations if p.role == ParticipationRole.DONOR)
    
    return ChallengeResponse(
        id=challenge.id,
        creator_id=challenge.creator_id,
        title=challenge.title,
        description=challenge.description,
        category=challenge.category,
        latitude=float(challenge.latitude),
        longitude=float(challenge.longitude),
        county=challenge.county,
        district=challenge.district,
        needed_resources=challenge.needed_resources,
        urgency_level=challenge.urgency_level,
        duration_days=challenge.duration_days,
        expected_impact=challenge.expected_impact,
        status=challenge.status,
        progress_percentage=float(challenge.progress_percentage),
        media_urls=challenge.media_urls,
        created_at=challenge.created_at,
        updated_at=challenge.updated_at,
        expires_at=challenge.expires_at,
        creator_name=challenge.creator.full_name if challenge.creator else None,
        participants_count=participants_count,
        volunteers_count=volunteers_count,
        donors_count=donors_count,
    )


@router.post("/{challenge_id}/join", response_model=ParticipationResponse)
async def join_challenge(
    challenge_id: UUID,
    body: ParticipationRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ParticipationResponse:
    """Join a challenge as participant, volunteer, or donor."""
    # Check if challenge exists
    challenge = await session.get(CommunityChallenge, challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    if challenge.status != ChallengeStatus.ACTIVE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot join challenge with status: {challenge.status}",
        )
    
    # Check if user already participated
    existing_stmt = select(ChallengeParticipation).where(
        ChallengeParticipation.challenge_id == challenge_id,
        ChallengeParticipation.user_id == user.id,
    )
    existing_result = await session.execute(existing_stmt)
    existing = existing_result.scalar_one_or_none()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already joined this challenge",
        )
    
    participation = ChallengeParticipation(
        user_id=user.id,
        challenge_id=challenge_id,
        role=body.role,
        contribution_details=body.contribution_details,
    )
    
    session.add(participation)
    await session.commit()
    await session.refresh(participation)
    
    return ParticipationResponse(
        id=participation.id,
        user_id=participation.user_id,
        challenge_id=participation.challenge_id,
        role=participation.role,
        contribution_details=participation.contribution_details,
        created_at=participation.created_at,
        user_name=user.full_name,
    )


@router.post("/{challenge_id}/progress", response_model=ProgressUpdateResponse)
async def update_progress(
    challenge_id: UUID,
    body: ProgressUpdateRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ProgressUpdateResponse:
    """Add a progress update to a challenge."""
    # Check if challenge exists
    challenge = await session.get(CommunityChallenge, challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    # Check if user is participating
    participation_stmt = select(ChallengeParticipation).where(
        ChallengeParticipation.challenge_id == challenge_id,
        ChallengeParticipation.user_id == user.id,
    )
    participation_result = await session.execute(participation_stmt)
    participation = participation_result.scalar_one_or_none()
    
    if not participation and challenge.creator_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You must join the challenge before adding progress updates",
        )
    
    progress = ChallengeProgress(
        challenge_id=challenge_id,
        user_id=user.id,
        description=body.description,
        media_urls=body.media_urls,
        progress_percentage=body.progress_percentage,
        milestone=body.milestone,
    )
    
    session.add(progress)
    
    # Update challenge progress
    challenge.progress_percentage = body.progress_percentage
    challenge.updated_at = datetime.utcnow()
    
    # Auto-complete if progress reaches 100%
    if body.progress_percentage >= 100:
        challenge.status = ChallengeStatus.COMPLETED
    
    await session.commit()
    await session.refresh(progress)
    
    return ProgressUpdateResponse(
        id=progress.id,
        challenge_id=progress.challenge_id,
        user_id=progress.user_id,
        description=progress.description,
        media_urls=progress.media_urls,
        progress_percentage=float(progress.progress_percentage),
        milestone=progress.milestone,
        created_at=progress.created_at,
        user_name=user.full_name,
    )


@router.post("/{challenge_id}/support", response_model=StakeholderSupportResponse)
async def provide_support(
    challenge_id: UUID,
    body: StakeholderSupportRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> StakeholderSupportResponse:
    """Provide stakeholder support (NGOs, government, etc.) to a challenge."""
    # Check if user is a stakeholder (NGO, government, admin)
    if user.role not in {"ngo", "government", "admin", "superadmin"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only verified stakeholders can provide support",
        )
    
    # Check if challenge exists
    challenge = await session.get(CommunityChallenge, challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    support = StakeholderSupport(
        stakeholder_id=user.id,
        challenge_id=challenge_id,
        support_type=body.support_type,
        details=body.details,
        is_high_priority=body.is_high_priority,
    )
    
    session.add(support)
    await session.commit()
    await session.refresh(support)
    await session.refresh(challenge)
    
    # Notify participants about stakeholder support
    try:
        await notify_stakeholder_support(
            session,
            challenge,
            user.full_name,
            body.support_type.value,
        )
    except Exception as e:
        import logging
        logging.warning(f"Failed to send stakeholder support notifications: {e}")
    
    return StakeholderSupportResponse(
        id=support.id,
        stakeholder_id=support.stakeholder_id,
        challenge_id=support.challenge_id,
        support_type=support.support_type,
        details=support.details,
        is_high_priority=support.is_high_priority,
        created_at=support.created_at,
        stakeholder_name=user.full_name,
    )


@router.get("/{challenge_id}/progress", response_model=list[ProgressUpdateResponse])
async def get_progress_updates(
    challenge_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    limit: int = Query(50, ge=1, le=100),
) -> list[ProgressUpdateResponse]:
    """Get progress updates for a challenge."""
    challenge = await session.get(CommunityChallenge, challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    stmt = (
        select(ChallengeProgress)
        .where(ChallengeProgress.challenge_id == challenge_id)
        .order_by(ChallengeProgress.created_at.desc())
        .limit(limit)
        .options(selectinload(ChallengeProgress.user))
    )
    
    result = await session.execute(stmt)
    progress_updates = result.scalars().all()
    
    return [
        ProgressUpdateResponse(
            id=p.id,
            challenge_id=p.challenge_id,
            user_id=p.user_id,
            description=p.description,
            media_urls=p.media_urls,
            progress_percentage=float(p.progress_percentage),
            milestone=p.milestone,
            created_at=p.created_at,
            user_name=p.user.full_name if p.user else None,
        )
        for p in progress_updates
    ]


@router.get("/{challenge_id}/participants", response_model=list[ParticipationResponse])
async def get_participants(
    challenge_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    role: Optional[str] = Query(None, description="Filter by role"),
) -> list[ParticipationResponse]:
    """Get list of participants for a challenge."""
    challenge = await session.get(CommunityChallenge, challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )
    
    stmt = (
        select(ChallengeParticipation)
        .where(ChallengeParticipation.challenge_id == challenge_id)
        .options(selectinload(ChallengeParticipation.user))
    )
    
    if role:
        stmt = stmt.where(ChallengeParticipation.role == ParticipationRole(role))
    
    result = await session.execute(stmt)
    participations = result.scalars().all()
    
    return [
        ParticipationResponse(
            id=p.id,
            user_id=p.user_id,
            challenge_id=p.challenge_id,
            role=p.role,
            contribution_details=p.contribution_details,
            created_at=p.created_at,
            user_name=p.user.full_name if p.user else None,
        )
        for p in participations
    ]
