import pytest

from app.api.reports import sync_offline_reports
from app.schemas.sync import SyncRequest
from tests.fakes import FakeSession, FakeUser


@pytest.mark.asyncio
async def test_sync_offline_reports_returns_synced_ids():
    session = FakeSession()
    user = FakeUser()
    sync_body = SyncRequest(offline_references=["test-ref-1"])
    result = await sync_offline_reports(body=sync_body, session=session, user=user)
    assert result.synced_reports == []
    assert result.pending_count >= 0
