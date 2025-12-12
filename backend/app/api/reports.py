from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..models.core import Comment, Location, Report, ReportMedia, Verification
from ..schemas.common import Location as LocationSchema
from ..schemas.common import MediaRef, ReportSummary
from ..schemas.report import (
    CommentRequest,
    ReportCreateRequest,
    ReportResponse,
    SearchResponse,
    VerificationRequest,
    ReportAssignmentRequest,
    ReportStatusUpdateRequest,
)
from ..schemas.sync import SyncRequest, SyncResponse
from ..services.verification import compute_outcome
from ..services.report_id import generate_report_id
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/reports", tags=["reports"])

# Allowed values for validation
ALLOWED_CATEGORIES = {
    "social",
    "economic",
    "religious",
    "political",
    "health",
    "violence",
    "infrastructure",
    "security",
}
ALLOWED_SEVERITIES = {"low", "medium", "high", "critical"}
ALLOWED_STATUSES = {
    "submitted",
    "under-review",
    "needs-info",
    "assigned",
    "verified",
    "rejected",
    "resolved",
}


def _validate_value(value: str | None, allowed: set[str], field: str) -> None:
    if value is None:
        return
    if value not in allowed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid {field}: '{value}'. Allowed: {sorted(allowed)}",
        )


def _to_location_schema(location: Location | None) -> LocationSchema:
    if not location:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Missing location")
    return LocationSchema(
        latitude=location.latitude,
        longitude=location.longitude,
        county=location.county,
        district=location.district,
        description=location.description,
    )


def _to_media_schema(media: list[ReportMedia]) -> list[MediaRef]:
    return [
        MediaRef(
            key=item.media_key,
            type=item.media_type,
            checksum=item.checksum,
            blur_faces=item.blurred,
            voice_masked=item.voice_masked,
        )
        for item in media
    ]


@router.post("/create", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
async def create_report(
    body: ReportCreateRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ReportResponse:
    _validate_value(body.category, ALLOWED_CATEGORIES, "category")
    _validate_value(body.severity, ALLOWED_SEVERITIES, "severity")

    location = Location(
        latitude=body.location.latitude,
        longitude=body.location.longitude,
        county=body.location.county,
        district=body.location.district,
        description=body.location.description,
    )
    session.add(location)
    await session.flush()

    # Generate unique report ID
    report_id = await generate_report_id(session=session)

    report = Report(
        report_id=report_id,
        user_id=user.id,
        location_id=location.id,
        category=body.category,
        severity=body.severity,
        summary=body.summary,
        details=body.details,
        anonymous=body.anonymous or False,
        witness_count=body.witness_count or 0,
    )
    session.add(report)
    await session.flush()

    for media in body.media:
        session.add(
            ReportMedia(
                report_id=report.id,
                media_key=media.key,
                media_type=media.type,
                checksum=media.checksum,
                blurred=media.blur_faces if media.blur_faces is not None else True,
                voice_masked=media.voice_masked if media.voice_masked is not None else False,
            )
        )

    # Calculate initial priority score
    try:
        from ..services.priority_scoring import update_report_priority
        await update_report_priority(session, report)
    except Exception:
        # Don't fail if priority calculation fails
        pass
    
    await session.commit()
    await session.refresh(report, attribute_names=["media", "location"])

    # Notify community members for attestation (in background, don't block response)
    # Note: In production, use a proper background task queue (Celery, RQ, etc.)
    try:
        from ..services.community_notifications import notify_community_for_attestation
        # Create a new session for background task to avoid session conflicts
        from ..database import SessionLocal
        async def _notify_background():
            async with SessionLocal() as bg_session:
                await notify_community_for_attestation(bg_session, report, location, radius_km=10.0)
        
        # Schedule background notification (simplified - in production use proper task queue)
        import asyncio
        asyncio.create_task(_notify_background())
    except Exception as e:
        # Don't fail report creation if notification fails
        import logging
        logging.error(f"Failed to send community notifications: {e}")

    return ReportResponse(
        id=report.id,
        report_id=report.report_id,
        status=report.status,
        updated_at=report.updated_at,
        created_at=report.created_at,
        summary=report.summary,
        details=report.details,
        category=report.category,
        severity=report.severity,
        location=_to_location_schema(report.location),
        verification_score=report.ai_severity_score,
        assigned_agency=report.recommended_agency,
        media=_to_media_schema(report.media),
        timeline=[],
    )


@router.get("/search", response_model=SearchResponse)
async def search_reports(
    session: AsyncSession = Depends(get_db_session),
    county: str | None = Query(default=None),
    category: str | None = Query(default=None),
    status_filter: str | None = Query(default=None, alias="status"),
    text: str | None = Query(default=None),
    severity: str | None = Query(default=None),
    assigned_agency: str | None = Query(default=None),
    min_priority: float | None = Query(default=None, ge=0.0, le=1.0),
    date_from: str | None = Query(default=None, description="ISO date string"),
    date_to: str | None = Query(default=None, description="ISO date string"),
    sort_by: str = Query(default="created_at", description="Sort field: created_at, severity, priority_score"),
    sort_order: str = Query(default="desc", description="Sort order: asc or desc"),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    user=Depends(get_current_user),
) -> SearchResponse:
    _validate_value(category, ALLOWED_CATEGORIES, "category")
    _validate_value(severity, ALLOWED_SEVERITIES, "severity")
    _validate_value(status_filter, ALLOWED_STATUSES, "status")
    
    if sort_by not in {"created_at", "severity", "priority_score", "updated_at"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid sort_by: '{sort_by}'. Allowed: created_at, severity, priority_score, updated_at",
        )
    if sort_order not in {"asc", "desc"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid sort_order: '{sort_order}'. Allowed: asc, desc",
        )

    stmt = select(Report).options(selectinload(Report.location))
    if county:
        stmt = stmt.join(Location).where(Location.county == county)
    if category:
        stmt = stmt.where(Report.category == category)
    if severity:
        stmt = stmt.where(Report.severity == severity)
    if status_filter:
        stmt = stmt.where(Report.status == status_filter)
    if assigned_agency:
        stmt = stmt.where(Report.recommended_agency.ilike(f"%{assigned_agency}%"))
    if min_priority is not None:
        stmt = stmt.where(Report.priority_score >= min_priority)
    if text:
        # Full-text search across summary and details
        stmt = stmt.where(
            (Report.summary.ilike(f"%{text}%")) | (Report.details.ilike(f"%{text}%"))
        )
    if date_from:
        from datetime import datetime
        try:
            date_from_dt = datetime.fromisoformat(date_from.replace("Z", "+00:00"))
            stmt = stmt.where(Report.created_at >= date_from_dt)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid date_from format. Use ISO 8601 format.",
            )
    if date_to:
        from datetime import datetime
        try:
            date_to_dt = datetime.fromisoformat(date_to.replace("Z", "+00:00"))
            stmt = stmt.where(Report.created_at <= date_to_dt)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid date_to format. Use ISO 8601 format.",
            )

    # Get total count (before pagination) - reuse same filters
    count_stmt = select(func.count(Report.id))
    # Apply same filters as main query
    if county:
        count_stmt = count_stmt.join(Location).where(Location.county == county)
    if category:
        count_stmt = count_stmt.where(Report.category == category)
    if severity:
        count_stmt = count_stmt.where(Report.severity == severity)
    if status_filter:
        count_stmt = count_stmt.where(Report.status == status_filter)
    if assigned_agency:
        count_stmt = count_stmt.where(Report.recommended_agency.ilike(f"%{assigned_agency}%"))
    if min_priority is not None:
        count_stmt = count_stmt.where(Report.priority_score >= min_priority)
    if text:
        count_stmt = count_stmt.where(
            (Report.summary.ilike(f"%{text}%")) | (Report.details.ilike(f"%{text}%"))
        )
    if date_from:
        from datetime import datetime
        date_from_dt = datetime.fromisoformat(date_from.replace("Z", "+00:00"))
        count_stmt = count_stmt.where(Report.created_at >= date_from_dt)
    if date_to:
        from datetime import datetime
        date_to_dt = datetime.fromisoformat(date_to.replace("Z", "+00:00"))
        count_stmt = count_stmt.where(Report.created_at <= date_to_dt)
    
    total_result = await session.execute(count_stmt)
    total = total_result.scalar() or 0

    # Apply sorting
    sort_column = {
        "created_at": Report.created_at,
        "severity": Report.severity,
        "priority_score": Report.priority_score,
        "updated_at": Report.updated_at,
    }.get(sort_by, Report.created_at)
    
    if sort_order == "desc":
        order_by = sort_column.desc()
    else:
        order_by = sort_column.asc()

    # Apply pagination
    offset = (page - 1) * page_size
    result = await session.execute(
        stmt.order_by(order_by).limit(page_size).offset(offset)
    )
    reports = result.scalars().unique().all()
    summaries = [
        ReportSummary(
            id=r.id,
            summary=r.summary,
            category=r.category,
            county=r.location.county if r.location else None,
            severity=r.severity,
            status=r.status,
        )
        for r in reports
    ]
    return SearchResponse(
        results=summaries,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size if total > 0 else 0,
    )


@router.get("/{report_id}", response_model=ReportResponse)
async def get_report(
    report_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> ReportResponse:
    stmt = (
        select(Report)
        .where(Report.id == report_id)
        .options(selectinload(Report.location), selectinload(Report.media))
    )
    result = await session.execute(stmt)
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")
    return ReportResponse(
        id=report.id,
        report_id=report.report_id,
        status=report.status,
        updated_at=report.updated_at,
        created_at=report.created_at,
        summary=report.summary,
        details=report.details,
        category=report.category,
        severity=report.severity,
        location=_to_location_schema(report.location),
        verification_score=report.ai_severity_score,
        assigned_agency=report.recommended_agency,
        media=_to_media_schema(report.media),
        timeline=[],
    )


@router.post("/{report_id}/verify")
async def verify_report(
    report_id: UUID,
    body: VerificationRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, str]:
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    verification = Verification(report_id=report.id, user_id=user.id, action=body.action, notes=body.comment)
    session.add(verification)

    if body.witness_count:
        report.witness_count = (report.witness_count or 0) + body.witness_count

    outcome = await compute_outcome(session, report)

    if body.action == "request_info":
        report.status = "needs-info"
    else:
        report.status = outcome.status
        report.ai_severity_score = outcome.score
    
    # Update priority score after verification
    try:
        from ..services.priority_scoring import update_report_priority
        await update_report_priority(session, report)
    except Exception:
        pass

    await session.commit()
    return {"status": report.status, "verification_score": str(report.ai_severity_score or 0)}


@router.post("/{report_id}/assign")
async def assign_report(
    report_id: UUID,
    body: ReportAssignmentRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, str | None]:
    """Assign a report to an agency/NGO and optionally set status."""
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    if user.role not in {"admin", "superadmin", "ngo"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to assign reports")

    if body.status:
        _validate_value(body.status, ALLOWED_STATUSES, "status")
        report.status = body.status
    else:
        report.status = "assigned"

    report.recommended_agency = body.agency
    await session.commit()
    return {
        "report_id": str(report.id),
        "status": report.status,
        "assigned_agency": report.recommended_agency,
        "note": body.note,
    }


@router.post("/{report_id}/status")
async def update_report_status(
    report_id: UUID,
    body: ReportStatusUpdateRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, str]:
    """Update report status with basic validation."""
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    if user.role not in {"admin", "superadmin", "ngo"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update status")

    _validate_value(body.status, ALLOWED_STATUSES, "status")
    report.status = body.status
    await session.commit()
    return {"report_id": str(report.id), "status": report.status, "note": body.note or ""}


@router.post("/{report_id}/comment", status_code=status.HTTP_201_CREATED)
async def comment_report(
    report_id: UUID,
    body: CommentRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, str]:
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    comment = Comment(
        report_id=report.id,
        user_id=user.id,
        visibility=body.visibility,
        body=body.body,
    )
    session.add(comment)
    await session.commit()
    return {"message": "Comment added", "comment_id": str(comment.id)}


@router.post("/sync", response_model=SyncResponse)
async def sync_offline_reports(
    body: SyncRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> SyncResponse:
    """Sync reports queued offline. Client sends offline_references to confirm upload."""
    synced_ids: list[UUID] = []
    stmt = select(Report).where(Report.user_id == user.id)
    if body.since:
        stmt = stmt.where(Report.created_at >= body.since)
    result = await session.execute(stmt.order_by(Report.created_at.desc()).limit(100))
    reports = result.scalars().all()
    for report in reports:
        if str(report.id) in body.offline_references or report.offline_reference in body.offline_references:
            synced_ids.append(report.id)
    return SyncResponse(synced_reports=synced_ids, pending_count=max(0, len(reports) - len(synced_ids)))


@router.delete("/{report_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_report(
    report_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> None:
    """Delete a report. Users can only delete their own reports."""
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")

    # Check ownership (user can only delete their own reports, admins can delete any)
    if report.user_id != user.id and user.role not in {"admin", "superadmin"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own reports",
        )

    await session.delete(report)
    await session.commit()


@router.delete("/", status_code=status.HTTP_200_OK)
async def delete_all_user_reports(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict[str, int]:
    """Delete all reports belonging to the current user."""
    stmt = select(Report).where(Report.user_id == user.id)
    result = await session.execute(stmt)
    reports = result.scalars().all()
    count = len(reports)

    for report in reports:
        await session.delete(report)

    await session.commit()
    return {"deleted_count": count, "message": f"Deleted {count} report(s)"}


@router.get("/track/{report_id}", response_model=dict)
async def track_report_public(
    report_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    """Public endpoint to track report status (no authentication required).
    
    Returns only public information:
    - report_id (public ID)
    - status
    - created_at
    - updated_at
    - category (general category, not sensitive details)
    
    Does NOT return:
    - Reporter information
    - Exact location details
    - Media files
    - Internal notes
    """
    stmt = select(Report).where(Report.report_id == report_id)
    result = await session.execute(stmt)
    report = result.scalar_one_or_none()
    
    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Report not found. Please check your report ID."
        )
    
    return {
        "report_id": report.report_id,
        "status": report.status,
        "category": report.category,
        "severity": report.severity,
        "created_at": report.created_at.isoformat(),
        "updated_at": report.updated_at.isoformat() if report.updated_at else None,
        "message": f"Report {report.report_id} is currently {report.status}."
    }
