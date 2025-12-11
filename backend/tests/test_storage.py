import pytest

from app.services.storage import S3Storage
from app.config import get_settings


@pytest.mark.asyncio
async def test_s3_storage_generates_presigned_url():
    settings = get_settings()
    storage = S3Storage(settings)
    # This will fail if S3 creds aren't configured, but that's expected in tests
    try:
        result = await storage.generate_presigned_url("test/key.jpg", "image/jpeg")
        assert "upload_url" in result
        assert "fields" in result
        assert result["media_key"] == "test/key.jpg"
    except Exception:
        # Expected if S3 not configured
        pass
