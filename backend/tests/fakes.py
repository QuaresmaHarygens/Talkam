from __future__ import annotations

from collections import defaultdict
from datetime import datetime
from typing import Any
from uuid import UUID, uuid4

from app.models.core import Comment, Location, Report, ReportMedia, User, Verification


class FakeSession:
    def __init__(self) -> None:
        self.users: dict[UUID, User] = {}
        self.locations: dict[UUID, Location] = {}
        self.reports: dict[UUID, Report] = {}
        self.media: dict[UUID, list[ReportMedia]] = defaultdict(list)
        self.comments: dict[UUID, list[Comment]] = defaultdict(list)
        self.verifications: dict[UUID, list[Verification]] = defaultdict(list)

    def add(self, obj: Any) -> None:
        if isinstance(obj, User):
            obj.id = getattr(obj, "id", None) or uuid4()
            obj.created_at = getattr(obj, "created_at", None) or datetime.utcnow()
            obj.role = obj.role or "citizen"
            self.users[obj.id] = obj
        elif isinstance(obj, Location):
            obj.id = getattr(obj, "id", None) or uuid4()
            self.locations[obj.id] = obj
        elif isinstance(obj, Report):
            obj.id = getattr(obj, "id", None) or uuid4()
            obj.status = obj.status or "submitted"
            obj.created_at = obj.created_at or datetime.utcnow()
            self.reports[obj.id] = obj
        elif isinstance(obj, ReportMedia):
            self.media[obj.report_id].append(obj)
        elif isinstance(obj, Comment):
            self.comments[obj.report_id].append(obj)
        elif isinstance(obj, Verification):
            self.verifications[obj.report_id].append(obj)

    async def flush(self) -> None:  # pragma: no cover - no-op
        return None

    async def commit(self) -> None:  # pragma: no cover - no-op
        return None

    async def rollback(self) -> None:  # pragma: no cover - no-op
        return None

    async def refresh(self, obj: Any, attribute_names: list[str] | None = None) -> None:
        if isinstance(obj, Report):
            if not attribute_names or "location" in attribute_names:
                obj.location = self.locations.get(obj.location_id)
            if not attribute_names or "media" in attribute_names:
                obj.media = self.media.get(obj.id, [])

    async def get(self, model: Any, obj_id: UUID) -> Any:
        if model is Report:
            report = self.reports.get(obj_id)
            if report and report.location_id:
                report.location = self.locations.get(report.location_id)
            return report
        if model is User:
            return self.users.get(obj_id)
        from app.models.notifications import Notification, Attestation
        if model is Notification:
            return None  # Notifications stored separately if needed
        if model is Attestation:
            return None
        return None

    async def execute(self, stmt: Any) -> Any:
        """Mock execute for select statements."""
        from sqlalchemy.sql.selectable import Select
        from sqlalchemy import func
        if isinstance(stmt, Select):
            # Check if it's an aggregate query (func.count, etc)
            columns = stmt.column_descriptions if hasattr(stmt, 'column_descriptions') else []
            is_aggregate = any('func' in str(col.get('expr', '')) for col in columns)
            
            reports = list(self.reports.values())
            # Mock result object
            class FakeResult:
                def scalar(self):
                    """For aggregate queries like COUNT."""
                    if is_aggregate:
                        return len(reports)
                    return None
                
                def scalar_one_or_none(self):
                    return reports[0] if reports else None
                
                def scalars(self):
                    class FakeScalars:
                        def all(self):
                            return reports
                        def unique(self):
                            return self
                    return FakeScalars()
                
                def one(self):
                    """For queries expecting one row."""
                    if is_aggregate:
                        from types import SimpleNamespace
                        return SimpleNamespace(county="Montserrado", report_count=len(reports), verified_count=0)
                    return None
                
                def all(self):
                    """For queries expecting multiple rows."""
                    if is_aggregate:
                        from types import SimpleNamespace
                        return [SimpleNamespace(county="Montserrado", report_count=len(reports), verified_count=0)]
                    return reports
            return FakeResult()
        return None


class FakeUser:
    def __init__(self, role: str = "citizen") -> None:
        self.id = uuid4()
        self.role = role
        self.full_name = "Test User"
        self.verified = False
