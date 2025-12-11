from __future__ import annotations

from datetime import datetime, timedelta
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status

from ..config import Settings, get_settings
from ..schemas.report import MediaRef
from ..services.storage import S3Storage
from .deps import get_current_user, get_settings_dep

router = APIRouter(prefix="/media", tags=["media"])


@router.post("/upload")
async def request_upload(
    body: MediaRef,
    settings: Settings = Depends(get_settings_dep),
    user=Depends(get_current_user),
) -> dict:
    """Generate presigned S3 URL for direct client upload."""
    storage = S3Storage(settings)
    content_type_map = {"photo": "image/jpeg", "video": "video/mp4", "audio": "audio/mpeg"}
    content_type = content_type_map.get(body.type, "application/octet-stream")
    key = body.key or f"media/{user.id}/{uuid4()}.{body.type}"
    url_data = await storage.generate_presigned_url(key, content_type)
    return {
        **url_data,
        "expires_at": (datetime.utcnow() + timedelta(seconds=url_data["expires_in"])).isoformat() + "Z",
    }
