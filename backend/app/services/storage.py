from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any

import aioboto3
from botocore.config import Config

from app.config import Settings


async def get_s3_client(settings: Settings):
    """Get S3 client for health checks."""
    session = aioboto3.Session()
    config = Config(signature_version="s3v4", region_name="us-east-1")
    return session.client(
        "s3",
        endpoint_url=settings.s3_endpoint,
        aws_access_key_id=settings.s3_access_key,
        aws_secret_access_key=settings.s3_secret_key,
        config=config,
    )


class S3Storage:
    """S3-compatible storage client for media uploads."""

    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.session = aioboto3.Session()
        self.config = Config(signature_version="s3v4", region_name="us-east-1")

    async def generate_presigned_url(
        self, key: str, content_type: str, expires_in: int = 900
    ) -> dict[str, Any]:
        """Generate presigned POST URL for direct client upload."""
        async with self.session.client(
            "s3",
            endpoint_url=self.settings.s3_endpoint,
            aws_access_key_id=self.settings.s3_access_key,
            aws_secret_access_key=self.settings.s3_secret_key,
            config=self.config,
        ) as s3:
            conditions = [{"Content-Type": content_type}, ["content-length-range", 1, 50 * 1024 * 1024]]
            fields = {"Content-Type": content_type}
            url_data = await s3.generate_presigned_post(
                Bucket=self.settings.bucket_reports,
                Key=key,
                Fields=fields,
                Conditions=conditions,
                ExpiresIn=expires_in,
            )
            return {
                "upload_url": url_data["url"],
                "fields": url_data["fields"],
                "expires_in": expires_in,
                "media_key": key,
            }
