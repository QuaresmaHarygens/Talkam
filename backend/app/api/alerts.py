from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status

from app.config import get_settings
from app.schemas.alerts import AlertRequest
from app.services.alerts import AlertDispatcher

from .deps import get_current_user

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.post("/broadcast")
async def broadcast_alert(
    body: AlertRequest,
    user=Depends(get_current_user),
):
    if user.role not in {"admin", "government", "ngo"}:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient role")
    dispatcher = AlertDispatcher(get_settings())
    result = await dispatcher.broadcast(body.model_dump())
    return {"message": "Alert dispatched", "result": result}
