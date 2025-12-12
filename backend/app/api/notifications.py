"""API endpoints for user notifications."""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import Report
from ..models.notifications import Notification
from ..schemas.attestation import NotificationResponse
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationResponse])
async def get_notifications(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    unread_only: bool = Query(default=False, description="Only return unread notifications"),
    limit: int = Query(default=50, ge=1, le=100),
) -> list[NotificationResponse]:
    """Get notifications for the current user."""
    stmt = select(Notification).where(Notification.user_id == user.id)
    
    if unread_only:
        stmt = stmt.where(Notification.read == False)
    
    stmt = stmt.order_by(Notification.created_at.desc()).limit(limit)
    
    # Note: For challenge notifications, report_id will be None
    # The notification_type will indicate if it's a challenge notification
    
    result = await session.execute(stmt)
    notifications = result.scalars().all()
    
    # Load report summaries for each notification
    responses = []
    for notification in notifications:
        try:
            # Handle challenge notifications (no report_id)
            if notification.challenge_id and not notification.report_id:
                responses.append(
                    NotificationResponse(
                        id=str(notification.id),
                        report_id=None,  # Challenge notifications don't have report_id
                        title=notification.title,
                        message=notification.message,
                        read=notification.read,
                        action_taken=notification.action_taken,
                        created_at=notification.created_at.isoformat(),
                        report_summary=None,
                        report_category=None,
                        report_severity=None,
                    )
                )
                continue
            
            # Handle report notifications
            if notification.report_id:
                report = await session.get(Report, notification.report_id)
                responses.append(
                    NotificationResponse(
                        id=str(notification.id),
                        report_id=str(notification.report_id),
                        title=notification.title,
                        message=notification.message,
                        read=notification.read,
                        action_taken=notification.action_taken,
                        created_at=notification.created_at.isoformat(),
                        report_summary=report.summary if report else None,
                        report_category=report.category if report else None,
                        report_severity=report.severity if report else None,
                    )
                )
            else:
                # Notification with neither report_id nor challenge_id
                responses.append(
                    NotificationResponse(
                        id=str(notification.id),
                        report_id=None,
                        title=notification.title,
                        message=notification.message,
                        read=notification.read,
                        action_taken=notification.action_taken,
                        created_at=notification.created_at.isoformat(),
                        report_summary=None,
                        report_category=None,
                        report_severity=None,
                    )
                )
        except Exception as e:
            # If report doesn't exist or other error, still return notification without report details
            import logging
            logging.warning(f"Error loading notification {notification.id}: {e}")
            responses.append(
                NotificationResponse(
                    id=str(notification.id),
                    report_id=str(notification.report_id) if notification.report_id else None,
                    title=notification.title,
                    message=notification.message,
                    read=notification.read,
                    action_taken=notification.action_taken,
                    created_at=notification.created_at.isoformat(),
                    report_summary=None,
                    report_category=None,
                    report_severity=None,
                )
            )
    
    return responses


@router.post("/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, str]:
    """Mark a notification as read."""
    from uuid import UUID
    
    notification = await session.get(Notification, UUID(notification_id))
    if not notification:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    
    if notification.user_id != user.id:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your notification")
    
    from datetime import datetime
    notification.read = True
    notification.read_at = datetime.utcnow()
    
    await session.commit()
    
    return {"message": "Notification marked as read"}


@router.get("/unread/count")
async def get_unread_count(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, int]:
    """Get count of unread notifications."""
    from sqlalchemy import func
    
    stmt = select(func.count(Notification.id)).where(
        Notification.user_id == user.id,
        Notification.read == False,
    )
    
    result = await session.execute(stmt)
    count = result.scalar() or 0
    
    return {"unread_count": count}
