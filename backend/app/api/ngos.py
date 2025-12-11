from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..models.core import Location, NGO, Report
from ..schemas.common import ReportSummary
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/ngos", tags=["ngos"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register_ngo(
    body: dict,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> dict:
    if user.role not in {"ngo", "admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="NGO role required")
    ngo = NGO(
        name=body.get("name", user.full_name),
        contact_email=body.get("contact_email"),
        phone=body.get("phone"),
        focus=body.get("mission_focus"),
        counties=body.get("counties"),
        verified=False,
    )
    session.add(ngo)
    await session.commit()
    return {"id": str(ngo.id), "status": "pending"}


@router.get("/{ngo_id}/dashboard")
async def ngo_dashboard(
    ngo_id: str,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    county: str | None = Query(default=None),
    category: str | None = Query(default=None),
    status_filter: str | None = Query(default=None, alias="status"),
) -> dict:
    """NGO dashboard with filters and export links."""

    ngo = await session.get(NGO, ngo_id)
    if not ngo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="NGO not found")

    stmt = select(Report).options(selectinload(Report.location)).order_by(Report.created_at.desc())
    if county:
        stmt = stmt.join(Report.location).where(Location.county == county)
    if category:
        stmt = stmt.where(Report.category == category)
    if status_filter:
        stmt = stmt.where(Report.status == status_filter)

    result = await session.execute(stmt.limit(50))
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
    return {
        "pending_reports": summaries,
        "follow_ups": [],
        "exports": {
            "csv_url": f"/v1/ngos/{ngo_id}/export?format=csv&county={county or ''}&category={category or ''}",
            "pdf_url": f"/v1/ngos/{ngo_id}/export?format=pdf&county={county or ''}&category={category or ''}",
        },
    }


@router.get("/{ngo_id}/export")
async def ngo_export(
    ngo_id: str,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    format: str = "csv",
    county: str | None = None,
    category: str | None = None,
) -> dict:
    """Export NGO dashboard data (stub - returns placeholder URLs)."""
    ngo = await session.get(NGO, ngo_id)
    if not ngo:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="NGO not found")
    return {
        "export_url": f"https://api.talkamliberia.org/v1/exports/{ngo_id}_{format}_{datetime.utcnow().isoformat()}",
        "format": format,
        "status": "generating",
    }
