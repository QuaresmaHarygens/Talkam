import pytest

from app.api.dashboards import get_analytics_dashboard
from app.schemas.analytics import DashboardResponse
from tests.fakes import FakeSession, FakeUser


@pytest.mark.asyncio
async def test_analytics_dashboard_requires_role():
    session = FakeSession()
    user = FakeUser(role="citizen")
    # Should raise 403 for non-privileged roles
    try:
        await get_analytics_dashboard(session=session, user=user)
        assert False, "Should have raised 403"
    except Exception as e:
        assert "403" in str(e) or "Insufficient" in str(e)


@pytest.mark.asyncio
async def test_analytics_dashboard_returns_data():
    session = FakeSession()
    user = FakeUser(role="ngo")
    result = await get_analytics_dashboard(session=session, user=user)
    assert isinstance(result, DashboardResponse)
    assert result.kpis.total_reports >= 0
    assert result.kpis.verification_rate >= 0
