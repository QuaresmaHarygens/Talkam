"""Push notification service for mobile apps."""
from __future__ import annotations

import logging
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings
from app.models.device_tokens import DeviceToken

logger = logging.getLogger(__name__)


class PushNotificationService:
    """Service for sending push notifications via FCM/APNs."""
    
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.fcm_initialized = False
        self.apns_initialized = False
        
        # Initialize FCM if configured
        if settings.fcm_server_key or settings.fcm_project_id:
            try:
                import firebase_admin
                from firebase_admin import credentials, messaging
                
                # Try to initialize with credentials if available
                if hasattr(settings, 'fcm_credentials_path') and settings.fcm_credentials_path:
                    cred = credentials.Certificate(settings.fcm_credentials_path)
                    firebase_admin.initialize_app(cred)
                else:
                    # Use default credentials (for GCP environments)
                    try:
                        firebase_admin.initialize_app()
                    except ValueError:
                        # Already initialized
                        pass
                
                self.fcm_messaging = messaging
                self.fcm_initialized = True
                logger.info("FCM initialized successfully")
            except ImportError:
                logger.warning("firebase-admin not installed. Install with: pip install firebase-admin")
            except Exception as e:
                logger.warning(f"FCM initialization failed: {e}")
        
        # Initialize APNs if configured
        if settings.apns_key_path:
            try:
                from apns2.client import APNsClient
                from apns2.credentials import TokenCredentials
                
                cred = TokenCredentials(
                    auth_key_path=settings.apns_key_path,
                    auth_key_id=settings.apns_key_id or "",
                    team_id=settings.apns_team_id or "",
                )
                self.apns_client = APNsClient(
                    credentials=cred,
                    use_sandbox=settings.apns_use_sandbox,
                )
                self.apns_initialized = True
                logger.info("APNs initialized successfully")
            except ImportError:
                logger.warning("PyAPNs2 not installed. Install with: pip install PyAPNs2")
            except Exception as e:
                logger.warning(f"APNs initialization failed: {e}")
    
    async def _get_user_tokens(
        self,
        session: AsyncSession,
        user_id: str,
        platform: str | None = None,
    ) -> list[DeviceToken]:
        """Get active device tokens for a user."""
        query = select(DeviceToken).where(
            DeviceToken.user_id == user_id,
            DeviceToken.active == True,  # noqa: E712
        )
        if platform:
            query = query.where(DeviceToken.platform == platform)
        
        result = await session.execute(query)
        return list(result.scalars().all())
    
    async def send_to_user(
        self,
        session: AsyncSession,
        user_id: str,
        title: str,
        body: str,
        data: dict[str, Any] | None = None,
        platform: str | None = None,
    ) -> bool:
        """
        Send push notification to a specific user.
        
        Returns True if sent successfully, False otherwise.
        """
        tokens = await self._get_user_tokens(session, user_id, platform)
        
        if not tokens:
            logger.warning(f"No active device tokens found for user {user_id}")
            return False
        
        # Group tokens by platform
        android_tokens = [t.token for t in tokens if t.platform == "android"]
        ios_tokens = [t.token for t in tokens if t.platform == "ios"]
        web_tokens = [t.token for t in tokens if t.platform == "web"]
        
        success = False
        
        # Send to Android (FCM)
        if android_tokens and self.fcm_initialized:
            try:
                result = await self.send_to_tokens(android_tokens, title, body, data, "android")
                if result.get("sent", 0) > 0:
                    success = True
            except Exception as e:
                logger.error(f"Failed to send FCM notification: {e}")
        
        # Send to iOS (APNs)
        if ios_tokens and self.apns_initialized:
            try:
                result = await self.send_to_tokens(ios_tokens, title, body, data, "ios")
                if result.get("sent", 0) > 0:
                    success = True
            except Exception as e:
                logger.error(f"Failed to send APNs notification: {e}")
        
        # Web push (can use FCM for web)
        if web_tokens and self.fcm_initialized:
            try:
                result = await self.send_to_tokens(web_tokens, title, body, data, "web")
                if result.get("sent", 0) > 0:
                    success = True
            except Exception as e:
                logger.error(f"Failed to send web push notification: {e}")
        
        # Fallback: log if no services initialized
        if not self.fcm_initialized and not self.apns_initialized:
            logger.info(f"Push notification to user {user_id}: {title} - {body} (no push services configured)")
            return True  # Return True for stub mode
        
        return success
    
    async def send_to_tokens(
        self,
        tokens: list[str],
        title: str,
        body: str,
        data: dict[str, Any] | None = None,
        platform: str = "all",  # 'android', 'ios', 'web', 'all'
    ) -> dict[str, Any]:
        """
        Send push notification to specific device tokens.
        
        Returns delivery statistics.
        """
        if not tokens:
            return {"sent": 0, "failed": 0, "invalid_tokens": []}
        
        sent = 0
        failed = 0
        invalid_tokens = []
        
        # FCM (Android and Web)
        if platform in ["android", "web", "all"] and self.fcm_initialized:
            try:
                messages = []
                for token in tokens:
                    message = self.fcm_messaging.Message(
                        notification=self.fcm_messaging.Notification(
                            title=title,
                            body=body,
                        ),
                        data={str(k): str(v) for k, v in (data or {}).items()},
                        token=token,
                    )
                    messages.append(message)
                
                # Send in batches (FCM supports up to 500 per batch)
                batch_size = 500
                for i in range(0, len(messages), batch_size):
                    batch = messages[i:i + batch_size]
                    try:
                        response = self.fcm_messaging.send_all(batch)
                        sent += response.success_count
                        failed += response.failure_count
                        
                        # Track invalid tokens
                        for idx, result in enumerate(response.responses):
                            if not result.success:
                                invalid_tokens.append(batch[idx].token)
                    except Exception as e:
                        logger.error(f"FCM batch send failed: {e}")
                        failed += len(batch)
            except Exception as e:
                logger.error(f"FCM send failed: {e}")
                failed += len(tokens)
        
        # APNs (iOS)
        elif platform in ["ios", "all"] and self.apns_initialized:
            try:
                from apns2.payload import Payload
                
                payload = Payload(
                    alert=body,
                    badge=1,
                    sound="default",
                    custom=data or {},
                )
                
                for token in tokens:
                    try:
                        self.apns_client.send_notification(
                            token_hex=token,
                            notification=payload,
                            topic=self.settings.apns_bundle_id or "com.talkam.liberia",
                        )
                        sent += 1
                    except Exception as e:
                        logger.error(f"APNs send failed for token {token[:20]}...: {e}")
                        failed += 1
                        invalid_tokens.append(token)
            except Exception as e:
                logger.error(f"APNs send failed: {e}")
                failed += len(tokens)
        
        # Fallback: stub mode
        else:
            logger.info(f"Push notification (stub): {title} - {body} to {len(tokens)} tokens")
            sent = len(tokens)
        
        return {
            "sent": sent,
            "failed": failed,
            "invalid_tokens": invalid_tokens,
        }
    
    async def send_attestation_request(
        self,
        session: AsyncSession,
        user_id: str,
        report_id: str,
        report_summary: str,
        county: str,
    ) -> bool:
        """Send notification for attestation request."""
        return await self.send_to_user(
            session=session,
            user_id=user_id,
            title=f"New Report in {county}",
            body=f"A report was made near you: {report_summary[:100]}... Can you confirm?",
            data={
                "type": "attestation_request",
                "report_id": report_id,
                "action": "view_report",
            },
        )
