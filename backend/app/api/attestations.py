"""API endpoints for community attestation."""
from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import Location, Report
from ..schemas.attestation import AttestationRequest, AttestationResponse
from ..services.community_notifications import create_attestation
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/attestations", tags=["attestations"])


@router.post("/reports/{report_id}/attest", response_model=AttestationResponse, status_code=status.HTTP_201_CREATED)
async def attest_to_report(
    report_id: UUID,
    body: AttestationRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> AttestationResponse:
    """
    Allow community members to attest to a report.
    
    Actions:
    - 'confirm': User confirms the report is accurate
    - 'deny': User denies/disputes the report
    - 'needs_info': User needs more information
    """
    # Validate action
    if body.action not in {"confirm", "deny", "needs_info"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Action must be 'confirm', 'deny', or 'needs_info'",
        )
    
    # Validate confidence if provided
    if body.confidence and body.confidence not in {"high", "medium", "low"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Confidence must be 'high', 'medium', or 'low'",
        )
    
    # Get report
    report = await session.get(Report, report_id)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found")
    
    # Get report location
    report_location = None
    if report.location_id:
        from sqlalchemy import select
        from ..models.core import Location
        result = await session.execute(select(Location).where(Location.id == report.location_id))
        report_location = result.scalar_one_or_none()
    elif hasattr(report, 'location') and report.location:
        report_location = report.location
    
    # Get user location if provided
    user_location = None
    if body.latitude is not None and body.longitude is not None:
        user_location = (body.latitude, body.longitude)
    
    # Create attestation
    attestation = await create_attestation(
        session=session,
        report_id=report_id,
        user_id=user.id,
        anonymous_token_id=None,
        action=body.action,
        confidence=body.confidence,
        comment=body.comment,
        user_location=user_location,
        report_location=report_location,
    )
    
    await session.commit()
    
    # Update report witness count if confirmed
    if body.action == "confirm":
        report.witness_count = (report.witness_count or 0) + 1
    
    # Recalculate verification outcome and priority
    try:
        from ..services.verification import compute_outcome
        from ..services.priority_scoring import update_report_priority
        
        outcome = await compute_outcome(session, report)
        report.status = outcome.status
        report.ai_severity_score = outcome.score
        
        # Update priority score based on new attestation
        await update_report_priority(session, report)
    except Exception:
        # Don't fail if calculation fails
        pass
    
    await session.commit()
    
    return AttestationResponse(
        id=str(attestation.id),
        report_id=str(report_id),
        action=attestation.action,
        distance_km=attestation.distance_km,
        message=f"Thank you for your attestation. Your {body.action} has been recorded.",
    )
