"""Sentry error tracking configuration."""
from __future__ import annotations

import logging
from typing import Optional

try:
    import sentry_sdk
    from sentry_sdk.integrations.fastapi import FastApiIntegration
    from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration
    from sentry_sdk.integrations.logging import LoggingIntegration
    SENTRY_AVAILABLE = True
except ImportError:
    SENTRY_AVAILABLE = False


def init_sentry(
    dsn: Optional[str] = None,
    environment: str = "development",
    traces_sample_rate: float = 0.1,
    enable_tracing: bool = True,
) -> None:
    """Initialize Sentry error tracking."""
    if not SENTRY_AVAILABLE:
        logging.warning("Sentry SDK not installed. Install with: pip install sentry-sdk[fastapi]")
        return
    
    if not dsn:
        logging.warning("Sentry DSN not configured. Error tracking disabled.")
        return
    
    sentry_sdk.init(
        dsn=dsn,
        environment=environment,
        integrations=[
            FastApiIntegration(transaction_style="endpoint"),
            SqlalchemyIntegration(),
            LoggingIntegration(
                level=logging.INFO,
                event_level=logging.ERROR,
            ),
        ],
        traces_sample_rate=traces_sample_rate if enable_tracing else 0.0,
        profiles_sample_rate=0.1 if enable_tracing else 0.0,
        send_default_pii=False,  # Don't send PII by default
        before_send=filter_sensitive_data,
    )


def filter_sensitive_data(event, hint):
    """Filter sensitive data from Sentry events."""
    # Remove sensitive headers
    if "request" in event and "headers" in event["request"]:
        sensitive_headers = ["authorization", "cookie", "x-api-key", "x-sms-token"]
        for header in sensitive_headers:
            event["request"]["headers"].pop(header, None)
    
    # Remove sensitive context
    if "contexts" in event:
        event["contexts"].pop("request", None)
    
    return event
