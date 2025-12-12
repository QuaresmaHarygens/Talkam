"""Notification service for Community Challenge events."""
from __future__ import annotations

import logging
from typing import Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.challenges import CommunityChallenge, ChallengeParticipation, ChallengeProgress
from ..models.core import User
from ..models.notifications import Notification
from ..services.geo_clustering import get_challenges_in_radius, haversine_distance

logger = logging.getLogger(__name__)


async def notify_challenge_created(
    session: AsyncSession,
    challenge: CommunityChallenge,
    radius_km: float = 5.0,
) -> int:
    """
    Notify all users within radius about a new challenge.
    Returns count of notifications created.
    """
    try:
        # Get all users (we'll filter by location in the future if we store user locations)
        # For now, notify all active users
        stmt = select(User).where(User.verified == True)
        result = await session.execute(stmt)
        users = result.scalars().all()
        
        notifications_created = 0
        for user in users:
            # In a real implementation, we'd check user's location against challenge location
            # For now, create notification for all verified users
            notification = Notification(
                user_id=user.id,
                report_id=None,  # Challenge notifications don't have report_id
                challenge_id=challenge.id,
                notification_type="challenge_created",
                title=f"New Challenge: {challenge.title}",
                message=f"A new {challenge.category} challenge has been created in {challenge.county or 'your area'}. Join now!",
                read=False,
                action_taken=False,
            )
            session.add(notification)
            notifications_created += 1
        
        await session.commit()
        logger.info(f"Created {notifications_created} notifications for challenge {challenge.id}")
        return notifications_created
    except Exception as e:
        logger.error(f"Error creating challenge notifications: {e}", exc_info=True)
        await session.rollback()
        return 0


async def notify_challenge_progress(
    session: AsyncSession,
    challenge: CommunityChallenge,
    progress: ChallengeProgress,
    radius_km: float = 5.0,
) -> int:
    """
    Notify participants and nearby users about challenge progress update.
    Returns count of notifications created.
    """
    try:
        notifications_created = 0
        
        # Notify all participants
        participation_stmt = select(ChallengeParticipation).where(
            ChallengeParticipation.challenge_id == challenge.id
        )
        participation_result = await session.execute(participation_stmt)
        participations = participation_result.scalars().all()
        
        participant_user_ids = {p.user_id for p in participations}
        
        for user_id in participant_user_ids:
            notification = Notification(
                user_id=user_id,
                report_id=None,
                challenge_id=challenge.id,
                notification_type="challenge_progress",
                title=f"Progress Update: {challenge.title}",
                message=f"{progress.description[:100]}... Progress: {progress.progress_percentage}%",
                read=False,
                action_taken=False,
            )
            session.add(notification)
            notifications_created += 1
        
        await session.commit()
        logger.info(f"Created {notifications_created} progress notifications for challenge {challenge.id}")
        return notifications_created
    except Exception as e:
        logger.error(f"Error creating progress notifications: {e}", exc_info=True)
        await session.rollback()
        return 0


async def notify_volunteer_request(
    session: AsyncSession,
    challenge: CommunityChallenge,
    radius_km: float = 5.0,
) -> int:
    """
    Notify users within radius about volunteer request.
    Returns count of notifications created.
    """
    try:
        # Get all verified users
        stmt = select(User).where(User.verified == True)
        result = await session.execute(stmt)
        users = result.scalars().all()
        
        notifications_created = 0
        for user in users:
            notification = Notification(
                user_id=user.id,
                report_id=None,
                notification_type="volunteer_request",
                title=f"Volunteers Needed: {challenge.title}",
                message=f"{challenge.title} needs volunteers in {challenge.county or 'your area'}. Can you help?",
                read=False,
                action_taken=False,
            )
            session.add(notification)
            notifications_created += 1
        
        await session.commit()
        logger.info(f"Created {notifications_created} volunteer request notifications for challenge {challenge.id}")
        return notifications_created
    except Exception as e:
        logger.error(f"Error creating volunteer request notifications: {e}", exc_info=True)
        await session.rollback()
        return 0


async def notify_stakeholder_support(
    session: AsyncSession,
    challenge: CommunityChallenge,
    stakeholder_name: str,
    support_type: str,
) -> int:
    """
    Notify challenge participants about stakeholder support.
    Returns count of notifications created.
    """
    try:
        notifications_created = 0
        
        # Notify all participants
        participation_stmt = select(ChallengeParticipation).where(
            ChallengeParticipation.challenge_id == challenge.id
        )
        participation_result = await session.execute(participation_stmt)
        participations = participation_result.scalars().all()
        
        participant_user_ids = {p.user_id for p in participations}
        
        for user_id in participant_user_ids:
            notification = Notification(
                user_id=user_id,
                report_id=None,
                challenge_id=challenge.id,
                notification_type="stakeholder_support",
                title=f"Support Received: {challenge.title}",
                message=f"{stakeholder_name} has provided {support_type} support to this challenge!",
                read=False,
                action_taken=False,
            )
            session.add(notification)
            notifications_created += 1
        
        await session.commit()
        logger.info(f"Created {notifications_created} stakeholder support notifications for challenge {challenge.id}")
        return notifications_created
    except Exception as e:
        logger.error(f"Error creating stakeholder support notifications: {e}", exc_info=True)
        await session.rollback()
        return 0

