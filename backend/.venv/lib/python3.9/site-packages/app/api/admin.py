from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.core import Flag, User
from .deps import get_current_user, get_db_session

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/flags")
async def list_flags(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> list[dict]:
    if user.role not in {"admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admins only")
    result = await session.execute(select(Flag).order_by(Flag.created_at.desc()).limit(50))
    flags = result.scalars().all()
    return [
        {
            "id": str(flag.id),
            "report_id": str(flag.report_id),
            "reason": flag.reason,
            "status": flag.status,
            "created_at": flag.created_at.isoformat(),
        }
        for flag in flags
    ]


@router.get("/users")
async def list_users(
    session: AsyncSession = Depends(get_db_session),
    user=Depends(get_current_user),
) -> list[dict]:
    if user.role not in {"admin", "superadmin"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admins only")
    result = await session.execute(select(User).order_by(User.created_at.desc()).limit(50))
    users = result.scalars().all()
    return [
        {
            "id": str(u.id),
            "display_name": u.full_name,
            "role": u.role,
            "verified": u.verified,
            "created_at": u.created_at.isoformat(),
        }
        for u in users
    ]
