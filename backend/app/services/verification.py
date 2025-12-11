from __future__ import annotations

from dataclasses import dataclass

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.core import Report, Verification
from app.models.notifications import Attestation

CONFIRM_THRESHOLD = 3
REJECT_THRESHOLD = 2
COMMUNITY_CONFIRM_THRESHOLD = 2  # Community attestations needed


@dataclass
class VerificationOutcome:
    status: str
    confirm_count: int
    reject_count: int
    score: float


async def compute_outcome(session: AsyncSession, report: Report) -> VerificationOutcome:
    """
    Compute verification outcome using multi-verifier consensus.
    
    Considers:
    - NGO/Admin verifications (Verification model)
    - Community attestations (Attestation model)
    """
    # Get NGO/Admin verifications
    verification_stmt = select(
        func.sum(case((Verification.action == "confirm", 1), else_=0)).label("confirm_count"),
        func.sum(case((Verification.action == "reject", 1), else_=0)).label("reject_count"),
    ).where(Verification.report_id == report.id)
    verification_result = await session.execute(verification_stmt)
    verification_counts = verification_result.one()
    verification_confirm = int(verification_counts.confirm_count or 0)
    verification_reject = int(verification_counts.reject_count or 0)
    
    # Get community attestations
    attestation_stmt = select(
        func.sum(case((Attestation.action == "confirm", 1), else_=0)).label("confirm_count"),
        func.sum(case((Attestation.action == "deny", 1), else_=0)).label("reject_count"),
    ).where(Attestation.report_id == report.id)
    attestation_result = await session.execute(attestation_stmt)
    attestation_counts = attestation_result.one()
    attestation_confirm = int(attestation_counts.confirm_count or 0)
    attestation_reject = int(attestation_counts.reject_count or 0)
    
    # Combine counts (weight NGO/Admin verifications more)
    # NGO/Admin verifications count as 2x
    total_confirm = (verification_confirm * 2) + attestation_confirm
    total_reject = (verification_reject * 2) + attestation_reject
    total = total_confirm + total_reject or 1
    
    # Calculate score
    score = round(total_confirm / total, 2) if total > 0 else 0.0
    
    # Determine status based on consensus
    # Need either: 3 NGO/Admin confirms OR 2 NGO/Admin + 2 community confirms
    ngo_admin_sufficient = verification_confirm >= CONFIRM_THRESHOLD
    community_sufficient = (verification_confirm >= 1 and attestation_confirm >= COMMUNITY_CONFIRM_THRESHOLD)
    combined_sufficient = total_confirm >= (CONFIRM_THRESHOLD * 2)
    
    if ngo_admin_sufficient or community_sufficient or combined_sufficient:
        status = "verified"
    elif total_reject >= (REJECT_THRESHOLD * 2):
        status = "rejected"
    else:
        status = "under-review"

    return VerificationOutcome(
        status=status,
        confirm_count=total_confirm,
        reject_count=total_reject,
        score=score,
    )
