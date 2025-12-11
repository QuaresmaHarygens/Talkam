from __future__ import annotations

import os
from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Talkam Liberia API"
    api_v1_prefix: str = "/v1"
    secret_key: str
    access_token_expire_minutes: int = 60
    refresh_token_expire_minutes: int = 60 * 24 * 7

    # Support both DATABASE_URL (Railway/Heroku) and POSTGRES_DSN
    postgres_dsn: str = ""
    database_url: str | None = None
    
    @property
    def effective_postgres_dsn(self) -> str:
        """Get PostgreSQL DSN, supporting both DATABASE_URL and POSTGRES_DSN."""
        # Railway/Heroku provide DATABASE_URL
        database_url = self.database_url or os.getenv("DATABASE_URL", "")
        
        if database_url:
            # Convert postgresql:// to postgresql+asyncpg:// if needed
            if database_url.startswith("postgresql://") and "+asyncpg" not in database_url:
                return database_url.replace("postgresql://", "postgresql+asyncpg://", 1)
            return database_url
        
        # Fall back to POSTGRES_DSN
        if self.postgres_dsn:
            return self.postgres_dsn
        
        raise ValueError("Either DATABASE_URL or POSTGRES_DSN must be set")
    
    redis_url: str
    s3_endpoint: str | None = None
    s3_access_key: str | None = None
    s3_secret_key: str | None = None
    bucket_reports: str = "talkam-media"

    rabbitmq_url: str | None = None
    sms_gateway_url: str | None = None
    sms_gateway_token: str | None = None

    admin_contact_email: str = "security@talkamliberia.org"
    
    # Sentry configuration
    sentry_dsn: str | None = None
    sentry_environment: str = "development"
    sentry_traces_sample_rate: float = 0.1
    enable_sentry: bool = False
    
    # Push notification configuration
    fcm_server_key: str | None = None
    fcm_project_id: str | None = None
    apns_key_path: str | None = None
    apns_key_id: str | None = None
    apns_team_id: str | None = None
    apns_bundle_id: str | None = None
    apns_use_sandbox: bool = True

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()
