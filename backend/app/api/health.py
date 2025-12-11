"""Health check endpoints."""
from __future__ import annotations

from typing import Dict, Any

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import Settings, get_settings
from ..database import get_session

router = APIRouter(tags=["health"])


@router.get("/health")
async def health_check() -> Dict[str, str]:
    """Basic health check endpoint."""
    return {
        "status": "healthy",
        "service": "talkam-api",
    }


@router.get("/health/db")
async def health_db(
    session: AsyncSession = Depends(get_session),
) -> Dict[str, Any]:
    """Database health check."""
    try:
        result = await session.execute(text("SELECT 1"))
        result.scalar()
        
        # Get connection info
        db_version_result = await session.execute(text("SELECT version()"))
        db_version = db_version_result.scalar()
        
        return {
            "status": "healthy",
            "database": "connected",
            "version": db_version.split(",")[0] if db_version else "unknown",
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database connection failed: {str(e)}",
        ) from e


@router.get("/health/redis")
async def health_redis(settings: Settings = Depends(get_settings)) -> Dict[str, Any]:
    """Redis health check."""
    try:
        import redis.asyncio as redis
        
        client = await redis.from_url(settings.redis_url, decode_responses=True)
        await client.ping()
        info = await client.info("server")
        await client.aclose()
        
        return {
            "status": "healthy",
            "redis": "connected",
            "version": info.get("redis_version", "unknown"),
        }
    except ImportError:
        return {
            "status": "unknown",
            "redis": "not_configured",
            "message": "redis library not installed",
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Redis connection failed: {str(e)}",
        ) from e


@router.get("/health/storage")
async def health_storage(settings: Settings = Depends(get_settings)) -> Dict[str, Any]:
    """Storage (S3) health check."""
    if not settings.s3_endpoint or not settings.s3_access_key:
        return {
            "status": "unknown",
            "storage": "not_configured",
            "message": "S3 not configured",
        }
    
    try:
        from ..services.storage import get_s3_client
        
        s3_client = await get_s3_client(settings)
        async with s3_client as s3:
            # Try to list buckets or head bucket
            await s3.head_bucket(Bucket=settings.bucket_reports)
        
        return {
            "status": "healthy",
            "storage": "connected",
            "bucket": settings.bucket_reports,
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Storage connection failed: {str(e)}",
        ) from e


@router.get("/health/full")
async def health_full(
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> Dict[str, Any]:
    """Comprehensive health check of all services."""
    checks = {
        "service": "talkam-api",
        "status": "healthy",
        "checks": {},
    }
    
    overall_healthy = True
    
    # Database check
    try:
        await session.execute(text("SELECT 1"))
        checks["checks"]["database"] = {"status": "healthy"}
    except Exception as e:
        checks["checks"]["database"] = {"status": "unhealthy", "error": str(e)}
        overall_healthy = False
    
    # Redis check
    try:
        import redis.asyncio as redis
        client = await redis.from_url(settings.redis_url, decode_responses=True)
        await client.ping()
        await client.aclose()
        checks["checks"]["redis"] = {"status": "healthy"}
    except Exception as e:
        checks["checks"]["redis"] = {"status": "unhealthy", "error": str(e)}
        overall_healthy = False
    
    # Storage check
    if settings.s3_endpoint and settings.s3_access_key:
        try:
            from ..services.storage import get_s3_client
            s3_client = await get_s3_client(settings)
            async with s3_client as s3:
                await s3.head_bucket(Bucket=settings.bucket_reports)
            checks["checks"]["storage"] = {"status": "healthy"}
        except Exception as e:
            checks["checks"]["storage"] = {"status": "unhealthy", "error": str(e)}
            overall_healthy = False
    else:
        checks["checks"]["storage"] = {"status": "not_configured"}
    
    if not overall_healthy:
        checks["status"] = "degraded"
    
    return checks
