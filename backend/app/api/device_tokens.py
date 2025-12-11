"""API endpoints for device token management."""
from __future__ import annotations

from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import User
from ..models.device_tokens import DeviceToken
from ..schemas.device_tokens import (
    DeviceTokenListResponse,
    DeviceTokenRegisterRequest,
    DeviceTokenResponse,
)
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/device-tokens", tags=["device-tokens"])


@router.post("/register", response_model=DeviceTokenResponse, status_code=status.HTTP_201_CREATED)
async def register_device_token(
    body: DeviceTokenRegisterRequest,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> DeviceTokenResponse:
    """Register or update a device token for push notifications."""
    # Validate platform
    if body.platform not in ["android", "ios", "web"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Platform must be 'android', 'ios', or 'web'",
        )

    # Check if token already exists
    result = await session.execute(
        select(DeviceToken).where(DeviceToken.token == body.token)
    )
    existing_token = result.scalar_one_or_none()

    if existing_token:
        # Update existing token
        existing_token.user_id = user.id if hasattr(user, "id") else None
        existing_token.platform = body.platform
        existing_token.app_version = body.app_version
        existing_token.device_info = body.device_info
        existing_token.active = True
        await session.commit()
        await session.refresh(existing_token)
        return DeviceTokenResponse(
            id=str(existing_token.id),
            platform=existing_token.platform,
            active=existing_token.active,
            created_at=existing_token.created_at.isoformat(),
            last_used_at=existing_token.last_used_at.isoformat() if existing_token.last_used_at else None,
        )

    # Create new token
    device_token = DeviceToken(
        user_id=user.id if hasattr(user, "id") else None,
        anonymous_token_id=None,  # Could be set for anonymous users
        token=body.token,
        platform=body.platform,
        app_version=body.app_version,
        device_info=body.device_info,
        active=True,
    )
    session.add(device_token)
    await session.commit()
    await session.refresh(device_token)

    return DeviceTokenResponse(
        id=str(device_token.id),
        platform=device_token.platform,
        active=device_token.active,
        created_at=device_token.created_at.isoformat() if device_token.created_at else datetime.utcnow().isoformat(),
        last_used_at=device_token.last_used_at.isoformat() if device_token.last_used_at else None,
    )


@router.get("", response_model=DeviceTokenListResponse)
async def list_device_tokens(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> DeviceTokenListResponse:
    """List all device tokens for the current user."""
    user_id = user.id if hasattr(user, "id") else None
    if not user_id:
        return DeviceTokenListResponse(tokens=[], total=0)

    result = await session.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == user_id,
            DeviceToken.active == True,  # noqa: E712
        )
    )
    tokens = result.scalars().all()

    return DeviceTokenListResponse(
        tokens=[
            DeviceTokenResponse(
                id=str(token.id),
                platform=token.platform,
                active=token.active,
                created_at=token.created_at.isoformat(),
                last_used_at=token.last_used_at.isoformat() if token.last_used_at else None,
            )
            for token in tokens
        ],
        total=len(tokens),
    )


@router.delete("/{token_id}", status_code=status.HTTP_204_NO_CONTENT)
async def unregister_device_token(
    token_id: UUID,
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> None:
    """Unregister a device token (mark as inactive)."""
    user_id = user.id if hasattr(user, "id") else None
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )

    result = await session.execute(
        select(DeviceToken).where(
            DeviceToken.id == token_id,
            DeviceToken.user_id == user_id,
        )
    )
    token = result.scalar_one_or_none()

    if not token:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device token not found",
        )

    token.active = False
    await session.commit()
