"""Tests for device token management."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.deps import get_current_user, get_db_session
from tests.fakes import FakeUser, FakeSession
from app.models.device_tokens import DeviceToken
from uuid import uuid4


@pytest.mark.asyncio
async def test_register_device_token():
    """Test device token registration."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/v1/device-tokens/register",
            json={
                "token": "test_fcm_token_12345",
                "platform": "android",
                "app_version": "1.0.0",
                "device_info": "Samsung Galaxy S21",
            },
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["platform"] == "android"
        assert data["active"] is True
        assert "id" in data
    
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_list_device_tokens():
    """Test listing device tokens."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    # Register a token first
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        await client.post(
            "/v1/device-tokens/register",
            json={
                "token": "test_token_list",
                "platform": "ios",
            },
        )
        
        # List tokens
        response = await client.get("/v1/device-tokens")
        assert response.status_code == 200
        data = response.json()
        assert "tokens" in data
        assert "total" in data
    
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_device_token_validation():
    """Test device token validation."""
    app.dependency_overrides[get_current_user] = lambda: FakeUser(role="admin")
    shared_session = FakeSession()
    
    async def _fake_db():
        yield shared_session
    
    app.dependency_overrides[get_db_session] = _fake_db
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Invalid platform
        response = await client.post(
            "/v1/device-tokens/register",
            json={
                "token": "test_token",
                "platform": "invalid_platform",
            },
        )
        assert response.status_code == 400
        
        # Missing token
        response = await client.post(
            "/v1/device-tokens/register",
            json={
                "platform": "android",
            },
        )
        assert response.status_code == 422  # Validation error
    
    app.dependency_overrides.clear()
