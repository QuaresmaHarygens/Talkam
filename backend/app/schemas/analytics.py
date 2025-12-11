from __future__ import annotations

from datetime import datetime
from typing import Any

from pydantic import BaseModel


class KPIMetrics(BaseModel):
    total_reports: int
    verified_reports: int
    verification_rate: float
    avg_response_time_hours: float
    offline_sync_success_rate: float
    active_alerts: int


class CountyBreakdown(BaseModel):
    county: str
    report_count: int
    verified_count: int
    avg_severity: str


class CategoryTrend(BaseModel):
    category: str
    count: int
    trend: str  # "up", "down", "stable"


class DashboardResponse(BaseModel):
    kpis: KPIMetrics
    county_breakdown: list[CountyBreakdown]
    category_trends: list[CategoryTrend]
    last_updated: datetime


class HeatmapPoint(BaseModel):
    latitude: float
    longitude: float
    county: str
    report_count: int
    avg_severity: float
    intensity: float


class CategoryInsight(BaseModel):
    category: str
    total_reports: int
    verified_reports: int
    verification_rate: float
    avg_severity: float
    avg_ai_score: float | None


class CategoryInsightsResponse(BaseModel):
    by_category: list[CategoryInsight]
    most_reported: str | None
    most_verified: str | None


class TimeSeriesPoint(BaseModel):
    period: str
    total_reports: int
    verified_reports: int


class TimeSeriesResponse(BaseModel):
    data: list[TimeSeriesPoint]
    group_by: str
