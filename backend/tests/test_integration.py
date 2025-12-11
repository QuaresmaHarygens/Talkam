import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.deps import get_current_user, get_db_session
from tests.fakes import FakeUser, FakeSession


@pytest.mark.asyncio
async def test_api_healthcheck():
    """Test API health endpoint."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_anonymous_auth_flow():
    """Test anonymous authentication flow."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/v1/auth/anonymous-start",
            json={"device_hash": "test-device-123", "county": "Montserrado"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "token" in data
        assert data["expires_in"] > 0


@pytest.mark.asyncio
async def test_report_creation_flow():
    """Test complete report creation flow."""
    # Override dependencies to avoid DB/auth
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()

    async def _fake_db():
        yield shared_session

    app.dependency_overrides[get_db_session] = _fake_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        report_response = await client.post(
            "/v1/reports/create",
            json={
                "category": "infrastructure",
                "severity": "high",
                "summary": "Test road blockage",
                "location": {
                    "latitude": 6.3,
                    "longitude": -10.8,
                    "county": "Montserrado",
                },
                "anonymous": True,
            },
        )
        assert report_response.status_code == 201
        report_data = report_response.json()
        assert report_data["summary"] == "Test road blockage"
        assert report_data["status"] == "submitted"

        # Verify report can be retrieved
        report_id = report_data["id"]
        get_response = await client.get(
            f"/v1/reports/{report_id}",
        )
        assert get_response.status_code == 200

    app.dependency_overrides.pop(get_current_user, None)
    app.dependency_overrides.pop(get_db_session, None)


@pytest.mark.asyncio
async def test_search_validation_error_shape():
    """Ensure invalid filters return structured error envelope."""
    # Override dependencies to avoid real DB/auth
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")

    async def _fake_db():
        yield FakeSession()

    app.dependency_overrides[get_db_session] = _fake_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/v1/reports/search", params={"category": "not-valid"})
        assert response.status_code == 400
        body = response.json()
        assert "error" in body
        assert body["error"]["code"] == 400
        assert "Invalid category" in body["error"]["message"]

    # cleanup overrides
    app.dependency_overrides.pop(get_current_user, None)
    app.dependency_overrides.pop(get_db_session, None)


@pytest.mark.asyncio
async def test_verification_flow():
    """Test report verification workflow."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Create report (simplified - would need real user/auth)
        # This test demonstrates the verification endpoint structure
        # In production, you'd create a report first, then verify it
        pass  # Placeholder for full integration test with DB
