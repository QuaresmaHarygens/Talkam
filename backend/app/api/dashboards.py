from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.analytics import (
    CategoryInsightsResponse,
    CategoryTrend,
    CountyBreakdown,
    DashboardResponse,
    HeatmapPoint,
    KPIMetrics,
    TimeSeriesResponse,
)
from app.services.analytics import (
    compute_category_insights,
    compute_category_trends,
    compute_county_breakdown,
    compute_geographic_heatmap,
    compute_kpis,
    compute_time_series,
)

from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/dashboards", tags=["dashboards"])


@router.get("/analytics", response_model=DashboardResponse)
async def get_analytics_dashboard(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> DashboardResponse:
    """Get analytics dashboard data (NGO/Gov/Admin only)."""
    if user.role not in {"ngo", "government", "admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")

    kpi_data = await compute_kpis(session)
    county_data = await compute_county_breakdown(session)
    trend_data = await compute_category_trends(session)

    return DashboardResponse(
        kpis=KPIMetrics(**kpi_data),
        county_breakdown=[CountyBreakdown(**c) for c in county_data],
        category_trends=[CategoryTrend(**t) for t in trend_data],
        last_updated=datetime.utcnow(),
    )


@router.get("/heatmap", response_model=list[HeatmapPoint])
async def get_geographic_heatmap(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    days: int = 30,
) -> list[HeatmapPoint]:
    """Get geographic heatmap data for reports."""
    if user.role not in {"ngo", "government", "admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")
    
    heatmap_data = await compute_geographic_heatmap(session, days=days)
    return [HeatmapPoint(**point) for point in heatmap_data]


@router.get("/category-insights", response_model=CategoryInsightsResponse)
async def get_category_insights(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> CategoryInsightsResponse:
    """Get detailed insights by category."""
    if user.role not in {"ngo", "government", "admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")
    
    insights = await compute_category_insights(session)
    return CategoryInsightsResponse(**insights)


@router.get("/time-series", response_model=TimeSeriesResponse)
async def get_time_series(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
    days: int = 30,
    group_by: str = "day",
) -> TimeSeriesResponse:
    """Get time series data for reports."""
    if user.role not in {"ngo", "government", "admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")
    
    if group_by not in {"day", "week", "month"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="group_by must be 'day', 'week', or 'month'",
        )
    
    time_series_data = await compute_time_series(session, days=days, group_by=group_by)
    return TimeSeriesResponse(data=time_series_data, group_by=group_by)
