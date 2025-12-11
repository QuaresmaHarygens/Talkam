"""Priority scoring system for reports."""
from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import Report
from ..models.notifications import Attestation


async def calculate_priority_score(
    session: AsyncSession,
    report: Report,
) -> float:
    """
    Calculate priority score (0.0-1.0) for a report.
    
    Factors considered:
    - Severity level
    - Number of attestations (confirmations)
    - Time since creation (urgency)
    - Category importance
    - AI severity score (if available)
    - Witness count
    """
    score = 0.0
    
    # 1. Severity weight (40% of score)
    severity_weights = {
        "critical": 1.0,
        "high": 0.75,
        "medium": 0.5,
        "low": 0.25,
    }
    severity_score = severity_weights.get(report.severity.lower(), 0.5)
    score += severity_score * 0.4
    
    # 2. Attestation count (20% of score)
    from sqlalchemy import select, func
    attestation_stmt = select(func.count(Attestation.id)).where(
        Attestation.report_id == report.id,
        Attestation.action == "confirm",
    )
    attestation_result = await session.execute(attestation_stmt)
    confirm_count = attestation_result.scalar() or 0
    
    # Normalize: 0 confirmations = 0, 5+ confirmations = 1.0
    attestation_score = min(confirm_count / 5.0, 1.0)
    score += attestation_score * 0.2
    
    # 3. AI severity score (20% of score, if available)
    if report.ai_severity_score is not None:
        score += report.ai_severity_score * 0.2
    else:
        # If no AI score, use half weight
        score += 0.1
    
    # 4. Witness count (10% of score)
    witness_score = min((report.witness_count or 0) / 10.0, 1.0)
    score += witness_score * 0.1
    
    # 5. Category importance (10% of score)
    critical_categories = {"violence", "security", "health"}
    if report.category.lower() in critical_categories:
        category_score = 1.0
    else:
        category_score = 0.5
    score += category_score * 0.1
    
    # Ensure score is between 0.0 and 1.0
    return min(max(score, 0.0), 1.0)


async def update_report_priority(
    session: AsyncSession,
    report: Report,
) -> float:
    """Calculate and update report priority score."""
    priority_score = await calculate_priority_score(session, report)
    report.priority_score = priority_score
    await session.flush()
    return priority_score
