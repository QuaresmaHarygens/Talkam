"""Report ID generation service.

Generates unique report IDs in format: RPT-YYYY-XXXXXX
"""
import datetime
from sqlalchemy import select, func, extract
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import SessionLocal
from app.models.core import Report


from typing import Optional


async def generate_report_id(session: Optional[AsyncSession] = None) -> str:
    """Generate unique report ID: RPT-YYYY-XXXXXX
    
    Args:
        session: Optional database session. If not provided, creates a new one.
    
    Returns:
        Unique report ID string (e.g., "RPT-2025-000123")
    """
    year = datetime.datetime.now().year
    
    if session:
        # Use provided session
        from sqlalchemy import extract
        result = await session.execute(
            select(func.count(Report.id)).where(
                extract('year', Report.created_at) == year
            )
        )
        count = result.scalar() or 0
    else:
        # Create new session
        async with SessionLocal() as new_session:
            from sqlalchemy import extract
            result = await new_session.execute(
                select(func.count(Report.id)).where(
                    extract('year', Report.created_at) == year
                )
            )
            count = result.scalar() or 0
    
    # Format: RPT-2025-000123
    sequence = count + 1
    report_id = f"RPT-{year}-{str(sequence).zfill(6)}"
    
    return report_id


async def ensure_report_id_unique(report_id: str, session: AsyncSession) -> bool:
    """Check if report ID is unique.
    
    Args:
        report_id: Report ID to check
        session: Database session
    
    Returns:
        True if unique, False if exists
    """
    result = await session.execute(
        select(Report).where(Report.report_id == report_id)
    )
    existing = result.scalar_one_or_none()
    return existing is None

