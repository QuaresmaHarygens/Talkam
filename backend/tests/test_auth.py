import pytest

from app.api import auth as auth_module
from app.api.auth import register_user
from app.config import get_settings
from app.schemas.auth import RegisterRequest
from tests.fakes import FakeSession


class DummyPasswordContext:
    def hash(self, password: str) -> str:
        return f"hashed:{password}"


@pytest.mark.asyncio
async def test_register_user_returns_tokens(monkeypatch: pytest.MonkeyPatch):
    session = FakeSession()
    body = RegisterRequest(full_name="Tester", phone="+231700000000", password="safePass1", email="tester@example.com")
    settings = get_settings()
    monkeypatch.setattr(auth_module, "password_context", DummyPasswordContext())

    tokens = await register_user(body=body, session=session, settings=settings)

    assert tokens.access_token
    assert tokens.refresh_token
    assert session.users  # user persisted in fake session
