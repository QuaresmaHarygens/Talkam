"""Tests for enhanced analytics endpoints."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.deps import get_current_user, get_db_session
from tests.fakes import FakeUser, FakeSession


@pytest.mark.asyncio
async def test_analytics_endpoints():
    """Test analytics dashboard endpoints."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Get analytics dashboard
        response = await client.get("/v1/dashboards/analytics")
        assert response.status_code == 200
        data = response.json()
        assert "kpis" in data
        assert "county_breakdown" in data
        assert "category_trends" in data
        
        # Get heatmap
        response = await client.get("/v1/dashboards/heatmap?days=30")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        
        # Get category insights
        response = await client.get("/v1/dashboards/category-insights")
        assert response.status_code == 200
        data = response.json()
        assert "by_category" in data
        assert "most_reported" in data
        
        # Get time series
        response = await client.get("/v1/dashboards/time-series?days=30&group_by=day")
        assert response.status_code == 200
        data = response.json()
        assert "data" in data
        assert "group_by" in data
    
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_analytics_permissions():
    """Test analytics endpoints require admin/NGO role."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="citizen")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/v1/dashboards/analytics")
        assert response.status_code == 403
    
    app.dependency_overrides.clear()
