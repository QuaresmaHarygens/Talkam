from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.core import Location, Report


async def compute_kpis(session: AsyncSession) -> dict[str, Any]:
    """Compute key performance indicators."""
    total_stmt = select(func.count(Report.id))
    total_result = await session.execute(total_stmt)
    total_reports = total_result.scalar() or 0

    verified_stmt = select(func.count(Report.id)).where(Report.status == "verified")
    verified_result = await session.execute(verified_stmt)
    verified_reports = verified_result.scalar() or 0

    verification_rate = round((verified_reports / total_reports * 100) if total_reports > 0 else 0, 2)

    # Simplified response time (hours since creation for verified reports)
    response_stmt = select(
        func.avg(
            func.extract("epoch", Report.updated_at - Report.created_at) / 3600
        )
    ).where(Report.status == "verified")
    response_result = await session.execute(response_stmt)
    avg_response_hours = round(response_result.scalar() or 0, 2)

    return {
        "total_reports": total_reports,
        "verified_reports": verified_reports,
        "verification_rate": verification_rate,
        "avg_response_time_hours": avg_response_hours,
        "offline_sync_success_rate": 94.0,  # Stub
        "active_alerts": 0,  # Stub
    }


async def compute_county_breakdown(session: AsyncSession) -> list[dict[str, Any]]:
    """Break down reports by county."""
    stmt = (
        select(
            Location.county,
            func.count(Report.id).label("report_count"),
            func.sum(case((Report.status == "verified", 1), else_=0)).label("verified_count"),
        )
        .join(Report, Report.location_id == Location.id)
        .group_by(Location.county)
        .order_by(func.count(Report.id).desc())
        .limit(15)
    )
    result = await session.execute(stmt)
    return [
        {"county": row.county, "report_count": row.report_count, "verified_count": row.verified_count or 0}
        for row in result.all()
    ]


async def compute_category_trends(session: AsyncSession) -> list[dict[str, Any]]:
    """Compute category trends (simplified - compares last 7 days vs previous 7 days)."""
    week_ago = datetime.utcnow() - timedelta(days=7)
    two_weeks_ago = datetime.utcnow() - timedelta(days=14)

    recent_stmt = (
        select(Report.category, func.count(Report.id).label("count"))
        .where(Report.created_at >= week_ago)
        .group_by(Report.category)
    )
    recent_result = await session.execute(recent_stmt)
    recent_counts = {row.category: row.count for row in recent_result.all()}

    previous_stmt = (
        select(Report.category, func.count(Report.id).label("count"))
        .where(Report.created_at >= two_weeks_ago, Report.created_at < week_ago)
        .group_by(Report.category)
    )
    previous_result = await session.execute(previous_stmt)
    previous_counts = {row.category: row.count for row in previous_result.all()}

    trends = []
    all_categories = set(recent_counts.keys()) | set(previous_counts.keys())
    for cat in all_categories:
        recent = recent_counts.get(cat, 0)
        previous = previous_counts.get(cat, 0)
        if recent > previous:
            trend = "up"
        elif recent < previous:
            trend = "down"
        else:
            trend = "stable"
        trends.append({"category": cat, "count": recent, "trend": trend})

    return trends


async def compute_geographic_heatmap(
    session: AsyncSession,
    days: int = 30,
) -> list[dict[str, Any]]:
    """Compute geographic heatmap data for reports."""
    cutoff = datetime.utcnow() - timedelta(days=days)
    
    stmt = (
        select(
            Location.latitude,
            Location.longitude,
            Location.county,
            func.count(Report.id).label("report_count"),
            func.avg(
                case(
                    (Report.severity == "critical", 4),
                    (Report.severity == "high", 3),
                    (Report.severity == "medium", 2),
                    else_=1,
                )
            ).label("avg_severity"),
        )
        .join(Report, Report.location_id == Location.id)
        .where(Report.created_at >= cutoff)
        .group_by(Location.latitude, Location.longitude, Location.county)
        .having(func.count(Report.id) > 0)
    )
    
    result = await session.execute(stmt)
    return [
        {
            "latitude": float(row.latitude),
            "longitude": float(row.longitude),
            "county": row.county,
            "report_count": row.report_count,
            "avg_severity": float(row.avg_severity or 0),
            "intensity": min(row.report_count / 10.0, 1.0),  # Normalize to 0-1
        }
        for row in result.all()
    ]


async def compute_category_insights(session: AsyncSession) -> dict[str, Any]:
    """Compute detailed insights by category."""
    stmt = (
        select(
            Report.category,
            func.count(Report.id).label("total"),
            func.sum(case((Report.status == "verified", 1), else_=0)).label("verified"),
            func.avg(
                case(
                    (Report.severity == "critical", 4),
                    (Report.severity == "high", 3),
                    (Report.severity == "medium", 2),
                    else_=1,
                )
            ).label("avg_severity"),
            func.avg(Report.ai_severity_score).label("avg_ai_score"),
        )
        .group_by(Report.category)
    )
    
    result = await session.execute(stmt)
    categories = []
    
    for row in result.all():
        total = row.total
        verified = row.verified or 0
        categories.append({
            "category": row.category,
            "total_reports": total,
            "verified_reports": verified,
            "verification_rate": round((verified / total * 100) if total > 0 else 0, 2),
            "avg_severity": round(float(row.avg_severity or 0), 2),
            "avg_ai_score": round(float(row.avg_ai_score or 0), 2) if row.avg_ai_score else None,
        })
    
    return {
        "by_category": categories,
        "most_reported": max(categories, key=lambda x: x["total_reports"])["category"] if categories else None,
        "most_verified": max(categories, key=lambda x: x["verification_rate"])["category"] if categories else None,
    }


async def compute_time_series(
    session: AsyncSession,
    days: int = 30,
    group_by: str = "day",  # 'day', 'week', 'month'
) -> list[dict[str, Any]]:
    """Compute time series data for reports."""
    cutoff = datetime.utcnow() - timedelta(days=days)
    
    if group_by == "day":
        date_trunc = func.date_trunc("day", Report.created_at)
    elif group_by == "week":
        date_trunc = func.date_trunc("week", Report.created_at)
    else:  # month
        date_trunc = func.date_trunc("month", Report.created_at)
    
    stmt = (
        select(
            date_trunc.label("period"),
            func.count(Report.id).label("count"),
            func.sum(case((Report.status == "verified", 1), else_=0)).label("verified"),
        )
        .where(Report.created_at >= cutoff)
        .group_by(date_trunc)
        .order_by(date_trunc)
    )
    
    result = await session.execute(stmt)
    return [
        {
            "period": row.period.isoformat() if hasattr(row.period, "isoformat") else str(row.period),
            "total_reports": row.count,
            "verified_reports": row.verified or 0,
        }
        for row in result.all()
    ]
