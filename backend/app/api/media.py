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
    try:
        # Check if S3 is configured
        if not settings.s3_endpoint or not settings.s3_access_key or not settings.s3_secret_key:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Media storage is not configured. Please contact support.",
            )
        
        # Validate bucket name
        if not settings.bucket_reports:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Media storage bucket is not configured. Please contact support.",
            )
        
        storage = S3Storage(settings)
        content_type_map = {"photo": "image/jpeg", "video": "video/mp4", "audio": "audio/mpeg"}
        content_type = content_type_map.get(body.type, "application/octet-stream")
        key = body.key or f"media/{user.id}/{uuid4()}.{body.type}"
        
        try:
            url_data = await storage.generate_presigned_url(key, content_type)
            return {
                **url_data,
                "expires_at": (datetime.utcnow() + timedelta(seconds=url_data["expires_in"])).isoformat() + "Z",
            }
        except Exception as s3_error:
            import logging
            logging.error(f"S3 error generating presigned URL: {s3_error}", exc_info=True)
            # Provide more helpful error message
            error_msg = str(s3_error)
            if "bucket" in error_msg.lower() or "not found" in error_msg.lower():
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Media storage bucket not found or inaccessible. Please contact support.",
                )
            elif "credentials" in error_msg.lower() or "access" in error_msg.lower():
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Media storage authentication failed. Please contact support.",
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Failed to generate upload URL: {error_msg}",
                )
    except HTTPException:
        raise
    except Exception as e:
        import logging
        logging.error(f"Unexpected error generating upload URL: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate upload URL: {str(e)}",
        )
