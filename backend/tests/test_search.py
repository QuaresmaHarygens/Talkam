"""Tests for advanced search features."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.deps import get_current_user, get_db_session
from tests.fakes import FakeUser, FakeSession


@pytest.mark.asyncio
async def test_advanced_search_filters():
    """Test advanced search with multiple filters."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Search with category filter
        response = await client.get("/v1/reports/search?category=infrastructure")
        assert response.status_code == 200
        
        # Search with severity filter
        response = await client.get("/v1/reports/search?severity=high")
        assert response.status_code == 200
        
        # Search with priority filter
        response = await client.get("/v1/reports/search?min_priority=0.7")
        assert response.status_code == 200
        
        # Search with date range
        response = await client.get(
            "/v1/reports/search?date_from=2025-12-01T00:00:00Z&date_to=2025-12-08T23:59:59Z"
        )
        assert response.status_code == 200
        
        # Search with sorting
        response = await client.get(
            "/v1/reports/search?sort_by=priority_score&sort_order=desc"
        )
        assert response.status_code == 200
        
        # Full-text search
        response = await client.get("/v1/reports/search?text=road")
        assert response.status_code == 200
    
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_search_validation():
    """Test search parameter validation."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Invalid category
        response = await client.get("/v1/reports/search?category=invalid")
        assert response.status_code == 400
        
        # Invalid severity
        response = await client.get("/v1/reports/search?severity=invalid")
        assert response.status_code == 400
        
        # Invalid sort_by
        response = await client.get("/v1/reports/search?sort_by=invalid")
        assert response.status_code == 400
        
        # Invalid sort_order
        response = await client.get("/v1/reports/search?sort_order=invalid")
        assert response.status_code == 400
        
        # Invalid date format
        response = await client.get("/v1/reports/search?date_from=invalid-date")
        assert response.status_code == 400
    
    app.dependency_overrides.clear()
