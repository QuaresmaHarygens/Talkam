"""Service for notifying community members about new reports for attestation."""
from __future__ import annotations

import math
from typing import Optional
from uuid import UUID

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import Location, Report, User
from ..models.notifications import Attestation, Notification


def calculate_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two coordinates in kilometers using Haversine formula."""
    R = 6371  # Earth's radius in kilometers
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c


async def find_nearby_users(
    session: AsyncSession,
    report_location: Location,
    radius_km: float = 10.0,
    max_users: int = 50,
) -> list[User]:
    """
    Find users in the same county or within radius of report location.
    
    For now, we match by county since we don't track user locations.
    In production, you'd want to:
    1. Track user's last known location
    2. Use geospatial queries (PostGIS)
    3. Filter by distance using Haversine formula
    """
    # Find users in the same county
    # In a real implementation, you'd also check user's last known location
    stmt = (
        select(User)
        .where(User.role.in_(["citizen", "user"]))  # Only notify regular users, not admins/NGOs
        .limit(max_users)
    )
    
    result = await session.execute(stmt)
    users = result.scalars().all()
    
    # For now, return all users in the system (in production, filter by county/location)
    # This is a simplified implementation - in production you'd:
    # 1. Store user's county preference or last location
    # 2. Filter by actual distance
    return list(users)


async def notify_community_for_attestation(
    session: AsyncSession,
    report: Report,
    report_location: Location,
    radius_km: float = 10.0,
    send_push: bool = True,
) -> int:
    """
    Notify community members about a new report for attestation.
    
    Returns the number of notifications sent.
    """
    # Find nearby users
    nearby_users = await find_nearby_users(session, report_location, radius_km)
    
    if not nearby_users:
        return 0
    
    # Create notifications for each user
    notifications_created = 0
    for user in nearby_users:
        # Skip if user is the reporter
        if report.user_id and user.id == report.user_id:
            continue
        
        # Check if notification already exists
        existing = await session.execute(
            select(Notification).where(
                Notification.user_id == user.id,
                Notification.report_id == report.id,
            )
        )
        if existing.scalar_one_or_none():
            continue  # Already notified
        
        notification = Notification(
            user_id=user.id,
            report_id=report.id,
            notification_type="attestation_request",
            title=f"New Report in {report_location.county}",
            message=f"A {report.severity} {report.category} issue was reported near you. Can you confirm or provide additional information?",
        )
        session.add(notification)
        notifications_created += 1
        
        # Send push notification if enabled
        if send_push:
            try:
                from ..config import get_settings
                from ..services.push_notifications import PushNotificationService
                push_service = PushNotificationService(get_settings())
                await push_service.send_attestation_request(
                    session=session,
                    user_id=str(user.id),
                    report_id=str(report.id),
                    report_summary=report.summary,
                    county=report_location.county,
                )
            except Exception:
                # Don't fail if push notification fails
                import logging
                logging.warning(f"Failed to send push notification to user {user.id}")
    
    await session.flush()
    return notifications_created


async def create_attestation(
    session: AsyncSession,
    report_id: UUID,
    user_id: Optional[UUID],
    anonymous_token_id: Optional[UUID],
    action: str,  # 'confirm', 'deny', 'needs_info'
    confidence: Optional[str] = None,
    comment: Optional[str] = None,
    user_location: Optional[tuple[float, float]] = None,  # (lat, lon)
    report_location: Optional[Location] = None,
) -> Attestation:
    """Create an attestation from a community member."""
    
    # Calculate distance if locations provided
    distance_km = None
    if user_location and report_location and hasattr(report_location, 'latitude'):
        distance_km = calculate_distance_km(
            user_location[0],
            user_location[1],
            report_location.latitude,
            report_location.longitude,
        )
    
    attestation = Attestation(
        report_id=report_id,
        user_id=user_id,
        anonymous_token_id=anonymous_token_id,
        action=action,
        confidence=confidence,
        comment=comment,
        distance_km=round(distance_km, 2) if distance_km else None,
    )
    
    session.add(attestation)
    
    # Mark notification as action taken if user was notified
    if user_id:
        await session.execute(
            select(Notification).where(
                Notification.user_id == user_id,
                Notification.report_id == report_id,
            )
        )
        result = await session.execute(
            select(Notification).where(
                Notification.user_id == user_id,
                Notification.report_id == report_id,
            )
        )
        notification = result.scalar_one_or_none()
        if notification:
            notification.action_taken = True
    
    await session.flush()
    return attestation
