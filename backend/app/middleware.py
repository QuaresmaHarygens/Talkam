"""Middleware for rate limiting, CORS, and security headers."""
from __future__ import annotations

import time
from typing import Callable

from fastapi import Request, Response, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse

try:
    import redis.asyncio as redis
except ImportError:
    redis = None


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Rate limiting middleware using Redis."""

    def __init__(self, app, redis_url: str | None = None, default_limit: int = 100, window: int = 60):
        super().__init__(app)
        self.redis_url = redis_url
        self.default_limit = default_limit
        self.window = window
        self.redis_client: redis.Redis | None = None

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Skip rate limiting for health checks
        if request.url.path in ["/", "/health", "/health/db", "/health/redis"]:
            return await call_next(request)

        # Get client identifier
        client_id = self._get_client_id(request)

        # Check rate limit
        if await self._is_rate_limited(client_id, request.url.path):
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={
                    "error": "Rate limit exceeded",
                    "message": f"Too many requests. Limit: {self.default_limit} per {self.window}s",
                },
            )

        response = await call_next(request)

        # Add rate limit headers
        remaining = await self._get_remaining(client_id, request.url.path)
        response.headers["X-RateLimit-Limit"] = str(self.default_limit)
        response.headers["X-RateLimit-Remaining"] = str(max(0, remaining))
        response.headers["X-RateLimit-Reset"] = str(int(time.time()) + self.window)

        return response

    def _get_client_id(self, request: Request) -> str:
        """Get client identifier for rate limiting."""
        # Try to get user ID from token if available
        auth_header = request.headers.get("Authorization", "")
        if auth_header.startswith("Bearer "):
            # In production, decode JWT to get user ID
            # For now, use IP + path
            return f"{request.client.host}:{request.url.path}"

        # Fallback to IP address
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0].strip()
        return request.client.host if request.client else "unknown"

    async def _is_rate_limited(self, client_id: str, path: str) -> bool:
        """Check if client has exceeded rate limit."""
        if not self.redis_client or not self.redis_url:
            return False  # No rate limiting if Redis unavailable

        try:
            key = f"rate_limit:{client_id}:{path}"
            current = await self.redis_client.get(key)
            if current and int(current) >= self.default_limit:
                return True

            # Increment counter
            pipe = self.redis_client.pipeline()
            pipe.incr(key)
            pipe.expire(key, self.window)
            await pipe.execute()
            return False
        except Exception:
            # If Redis fails, allow request (fail open)
            return False

    async def _get_remaining(self, client_id: str, path: str) -> int:
        """Get remaining requests for client."""
        if not self.redis_client:
            return self.default_limit

        try:
            key = f"rate_limit:{client_id}:{path}"
            current = await self.redis_client.get(key)
            if current:
                return max(0, self.default_limit - int(current))
            return self.default_limit
        except Exception:
            return self.default_limit

    async def startup(self):
        """Initialize Redis connection."""
        if self.redis_url and redis:
            try:
                self.redis_client = await redis.from_url(self.redis_url, decode_responses=True)
            except Exception:
                pass  # Fail gracefully if Redis unavailable

    async def shutdown(self):
        """Close Redis connection."""
        if self.redis_client:
            await self.redis_client.aclose()


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to responses."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)

        # Security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

        return response
