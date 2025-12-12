from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from .api import admin, alerts, attestations, auth, challenges, dashboards, device_tokens, health, media, ngos, notifications, reports, sms
from .config import get_settings
from .middleware import RateLimitMiddleware, SecurityHeadersMiddleware
from .sentry_config import init_sentry

settings = get_settings()

# Initialize Sentry if configured
if settings.enable_sentry and settings.sentry_dsn:
    init_sentry(
        dsn=settings.sentry_dsn,
        environment=settings.sentry_environment,
        traces_sample_rate=settings.sentry_traces_sample_rate,
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    # Startup
    # Rate limiting middleware will initialize on first request
    # No startup needed here
    
    yield
    
    # Shutdown
    # Cleanup if needed
    pass


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    description="Talkam Liberia - Social Reporting System API",
    openapi_url=f"{settings.api_v1_prefix}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Global error envelope for consistency
@app.exception_handler(HTTPException)
async def http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": {"code": exc.status_code, "message": exc.detail}},
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(_: Request, exc: RequestValidationError) -> JSONResponse:
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": {
                "code": status.HTTP_422_UNPROCESSABLE_ENTITY,
                "message": "Validation error",
                "details": exc.errors(),
            }
        },
)

# CORS middleware
# In production, replace with specific domains:
# allow_origins=["https://admin.talkamliberia.org", "https://app.talkamliberia.org"]
# For development, allow all origins
import os
cors_origins = os.getenv("CORS_ORIGINS", "*")
if cors_origins == "*":
    allow_origins_list = ["*"]
else:
    allow_origins_list = [origin.strip() for origin in cors_origins.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
)

# Security headers middleware
app.add_middleware(SecurityHeadersMiddleware)

# Rate limiting middleware (optional, requires Redis)
if settings.redis_url:
    app.add_middleware(
        RateLimitMiddleware,
        redis_url=settings.redis_url,
        default_limit=100,  # requests per window
        window=60,  # seconds
    )

# Health check routes (no prefix)
app.include_router(health.router)

# API routes
app.include_router(auth.router, prefix=settings.api_v1_prefix)
app.include_router(reports.router, prefix=settings.api_v1_prefix)
app.include_router(media.router, prefix=settings.api_v1_prefix)
app.include_router(ngos.router, prefix=settings.api_v1_prefix)
app.include_router(admin.router, prefix=settings.api_v1_prefix)
app.include_router(alerts.router, prefix=settings.api_v1_prefix)
app.include_router(sms.router, prefix=settings.api_v1_prefix)
app.include_router(dashboards.router, prefix=settings.api_v1_prefix)
app.include_router(attestations.router, prefix=settings.api_v1_prefix)
app.include_router(notifications.router, prefix=settings.api_v1_prefix)
app.include_router(device_tokens.router, prefix=settings.api_v1_prefix)
app.include_router(challenges.router, prefix=settings.api_v1_prefix)


@app.get("/")
async def root() -> dict[str, str]:
    """Root endpoint with basic info."""
    return {
        "status": "ok",
        "app": settings.app_name,
        "version": "0.1.0",
        "docs": "/docs",
    }
