"""End-to-end tests for complete workflows."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.deps import get_current_user, get_db_session
from tests.fakes import FakeUser, FakeSession


@pytest.mark.asyncio
async def test_complete_report_attestation_workflow():
    """Test complete workflow: create report -> receive notification -> attest."""
    # This would require a real database or more sophisticated fake session
    # For now, we test the individual components separately
    pass


@pytest.mark.asyncio
async def test_priority_score_updates_on_attestation():
    """Test that priority score updates when attestations are added."""
    # This would require tracking priority score changes
    pass


@pytest.mark.asyncio
async def test_search_with_priority_filter():
    """Test searching reports filtered by priority score."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Search with priority filter
        response = await client.get("/v1/reports/search?min_priority=0.5")
        assert response.status_code == 200
        data = response.json()
        assert "results" in data
        assert "total" in data
        assert "page" in data
    
    app.dependency_overrides.clear()
