from datetime import datetime, timedelta
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from jose import jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import Settings
from ..models.core import User
from ..schemas.auth import (
    AnonymousStartRequest,
    AnonymousStartResponse,
    AuthTokens,
    ForgotPasswordRequest,
    LoginRequest,
    PasswordResetResponse,
    RegisterRequest,
    ResetPasswordRequest,
)
from .deps import get_db_session, get_settings_dep

router = APIRouter(prefix="/auth", tags=["auth"])
password_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _hash_password(password: str) -> str:
    return password_context.hash(password)


def _create_tokens(user_id: str, roles: list[str], settings: Settings) -> AuthTokens:
    now = datetime.utcnow()
    access_payload = {"sub": user_id, "roles": roles, "exp": now + timedelta(minutes=settings.access_token_expire_minutes)}
    refresh_payload = {"sub": user_id, "roles": roles, "exp": now + timedelta(minutes=settings.refresh_token_expire_minutes)}
    return AuthTokens(
        access_token=jwt.encode(access_payload, settings.secret_key, algorithm="HS256"),
        refresh_token=jwt.encode(refresh_payload, settings.secret_key, algorithm="HS256"),
        expires_in=settings.access_token_expire_minutes * 60,
        roles=roles,
    )


@router.post("/register", response_model=AuthTokens, status_code=status.HTTP_201_CREATED)
async def register_user(
    body: RegisterRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> AuthTokens:
    user = User(
        full_name=body.full_name,
        phone=body.phone,
        email=body.email,
        password_hash=_hash_password(body.password),
        language=body.language,
    )
    session.add(user)
    try:
        await session.commit()
    except IntegrityError as exc:
        await session.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User exists") from exc

    return _create_tokens(str(user.id), [user.role], settings)


@router.post("/login", response_model=AuthTokens)
async def login_user(
    body: LoginRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> AuthTokens:
    result = await session.execute(select(User).where(User.phone == body.phone))
    user = result.scalar_one_or_none()
    if not user or not password_context.verify(body.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    return _create_tokens(str(user.id), [user.role], settings)


@router.post("/anonymous-start", response_model=AnonymousStartResponse)
async def anonymous_start(
    body: AnonymousStartRequest,
    settings: Settings = Depends(get_settings_dep),
) -> AnonymousStartResponse:
    token_payload = {
        "sub": str(uuid4()),
        "type": "anon",
        "county": body.county,
        "capabilities": body.capabilities,
        "exp": datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes),
    }
    token = jwt.encode(token_payload, settings.secret_key, algorithm="HS256")
    return AnonymousStartResponse(token=token, expires_in=settings.access_token_expire_minutes * 60)


@router.post("/forgot-password", response_model=PasswordResetResponse)
async def forgot_password(
    body: ForgotPasswordRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> PasswordResetResponse:
    """Request password reset. Generates a reset token."""
    if not body.phone and not body.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone or email required",
        )

    # Find user by phone or email
    query = select(User)
    if body.phone:
        query = query.where(User.phone == body.phone)
    elif body.email:
        query = query.where(User.email == body.email)

    result = await session.execute(query)
    user = result.scalar_one_or_none()

    if not user:
        # Don't reveal if user exists for security
        return PasswordResetResponse(
            message="If an account exists, a reset link has been sent.",
            expires_in=3600,  # 1 hour
        )

    # Generate reset token (valid for 1 hour)
    reset_token_payload = {
        "sub": str(user.id),
        "type": "password_reset",
        "exp": datetime.utcnow() + timedelta(hours=1),
    }
    reset_token = jwt.encode(reset_token_payload, settings.secret_key, algorithm="HS256")

    # Send reset token via SMS or email
    reset_code = reset_token[:8].upper()  # First 8 chars as human-readable code
    try:
        from ..services.password_reset import send_password_reset
        sent = await send_password_reset(
            settings=settings,
            user_phone=user.phone,
            user_email=user.email,
            reset_token=reset_token,
            reset_code=reset_code,
        )
        if sent:
            return PasswordResetResponse(
                message="Password reset code sent. Check your phone/email.",
                expires_in=3600,
            )
        else:
            # If sending failed, still return success (don't reveal if user exists)
            return PasswordResetResponse(
                message="If an account exists, a reset link has been sent.",
                expires_in=3600,
            )
    except Exception as e:
        import logging
        logging.error(f"Error sending password reset: {e}")
        # Still return success to avoid revealing if user exists
        return PasswordResetResponse(
            message="If an account exists, a reset link has been sent.",
            expires_in=3600,
        )


@router.post("/reset-password", response_model=dict[str, str])
async def reset_password(
    body: ResetPasswordRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> dict[str, str]:
    """Reset password using reset token."""
    try:
        payload = jwt.decode(body.token, settings.secret_key, algorithms=["HS256"])
        if payload.get("type") != "password_reset":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid reset token",
            )

        user_id = UUID(payload["sub"])
        result = await session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        # Update password
        user.password_hash = _hash_password(body.new_password)
        await session.commit()

        return {"message": "Password reset successfully"}

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Reset token expired",
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid reset token",
        )
