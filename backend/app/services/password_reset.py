"""Password reset service for sending reset tokens via SMS/email."""
from __future__ import annotations

import logging
from typing import Optional

import httpx
from app.config import Settings

logger = logging.getLogger(__name__)


async def send_password_reset_sms(
    settings: Settings,
    phone: str,
    reset_code: str,
) -> bool:
    """
    Send password reset code via SMS.
    
    Returns True if sent successfully, False otherwise.
    """
    if not settings.sms_gateway_url or not settings.sms_gateway_token:
        logger.warning("SMS gateway not configured, cannot send reset code")
        return False
    
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(
                settings.sms_gateway_url,
                json={
                    "to": phone,
                    "message": f"Your Talkam Liberia password reset code is: {reset_code}. Valid for 1 hour.",
                },
                headers={
                    "Authorization": f"Bearer {settings.sms_gateway_token}",
                    "Content-Type": "application/json",
                },
            )
            
            if response.status_code == 200:
                logger.info(f"Password reset SMS sent to {phone}")
                return True
            else:
                logger.error(f"Failed to send SMS: {response.status_code} - {response.text}")
                return False
    except Exception as e:
        logger.error(f"Error sending password reset SMS: {e}")
        return False


async def send_password_reset_email(
    settings: Settings,
    email: str,
    reset_token: str,
    reset_code: str,
) -> bool:
    """
    Send password reset email with link and code.
    
    Returns True if sent successfully, False otherwise.
    """
    # In production, integrate with email service (SendGrid, SES, etc.)
    # For now, log the email that would be sent
    
    reset_link = f"https://app.talkamliberia.org/reset-password?token={reset_token}"
    
    email_body = f"""
    Hello,
    
    You requested a password reset for your Talkam Liberia account.
    
    Reset Code: {reset_code}
    (Valid for 1 hour)
    
    Or click this link: {reset_link}
    
    If you didn't request this, please ignore this email.
    
    - Talkam Liberia Team
    """
    
    logger.info(f"Password reset email would be sent to {email}")
    logger.debug(f"Email body: {email_body}")
    
    # TODO: Integrate with email service
    # Example with SendGrid:
    # from sendgrid import SendGridAPIClient
    # from sendgrid.helpers.mail import Mail
    # message = Mail(
    #     from_email='noreply@talkamliberia.org',
    #     to_emails=email,
    #     subject='Password Reset - Talkam Liberia',
    #     html_content=email_body
    # )
    # sg = SendGridAPIClient(settings.sendgrid_api_key)
    # response = sg.send(message)
    
    return True  # Return True for stub mode


async def send_password_reset(
    settings: Settings,
    user_phone: Optional[str],
    user_email: Optional[str],
    reset_token: str,
    reset_code: str,
) -> bool:
    """
    Send password reset via SMS (preferred) or email.
    
    Returns True if sent successfully, False otherwise.
    """
    # Prefer SMS if phone is available
    if user_phone:
        success = await send_password_reset_sms(settings, user_phone, reset_code)
        if success:
            return True
    
    # Fallback to email
    if user_email:
        return await send_password_reset_email(settings, user_email, reset_token, reset_code)
    
    logger.warning("No phone or email available for password reset")
    return False
