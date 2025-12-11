import pytest

from app.api import reports as reports_module
from fastapi import HTTPException

from app.api.reports import (
    create_report,
    verify_report,
    assign_report,
    update_report_status,
)
from app.services.verification import VerificationOutcome
from app.schemas.common import Location, MediaRef
from app.schemas.report import (
    ReportCreateRequest,
    VerificationRequest,
    ReportAssignmentRequest,
    ReportStatusUpdateRequest,
)
from tests.fakes import FakeSession, FakeUser


@pytest.mark.asyncio
async def test_create_report_persists_location_and_media():
    session = FakeSession()
    user = FakeUser()
    body = ReportCreateRequest(
        category="infrastructure",
        severity="high",
        summary="Bridge down",
        details="SAMPLE",
        location=Location(latitude=6.3, longitude=-10.8, county="Montserrado"),
        media=[MediaRef(key="media/test.jpg", type="photo", checksum="abc")],
    )

    response = await create_report(body=body, session=session, user=user)

    assert response.summary == "Bridge down"
    assert response.location.county == "Montserrado"
    assert response.media[0].key == "media/test.jpg"


@pytest.mark.asyncio
async def test_verify_report_updates_status(monkeypatch: pytest.MonkeyPatch):
    session = FakeSession()
    user = FakeUser(role="ngo")
    # seed report via create
    report_body = ReportCreateRequest(
        category="security",
        severity="medium",
        summary="Witness report",
        location=Location(latitude=6.5, longitude=-10.7, county="Bomi"),
    )
    report_response = await create_report(body=report_body, session=session, user=user)

    verification = VerificationRequest(action="confirm", comment="looks valid")
    async def fake_compute(*_, **__):
        return VerificationOutcome(status="verified", confirm_count=3, reject_count=0, score=1.0)

    monkeypatch.setattr(reports_module, "compute_outcome", fake_compute)
    result = await verify_report(report_id=report_response.id, body=verification, session=session, user=user)

    assert result["status"] == "verified"


@pytest.mark.asyncio
async def test_assign_report_sets_agency_and_status():
    session = FakeSession()
    admin_user = FakeUser(role="admin")
    report_body = ReportCreateRequest(
        category="security",
        severity="medium",
        summary="Bridge watch",
        location=Location(latitude=6.1, longitude=-10.5, county="Bomi"),
    )
    report_response = await create_report(body=report_body, session=session, user=admin_user)

    assignment = ReportAssignmentRequest(agency="LNP", status="assigned")
    result = await assign_report(
        report_id=report_response.id, body=assignment, session=session, user=admin_user
    )

    assert result["assigned_agency"] == "LNP"
    assert result["status"] == "assigned"


@pytest.mark.asyncio
async def test_update_report_status_validates_allowed_status():
    session = FakeSession()
    admin_user = FakeUser(role="admin")
    report_body = ReportCreateRequest(
        category="security",
        severity="medium",
        summary="Status change request",
        location=Location(latitude=6.2, longitude=-10.4, county="Bomi"),
    )
    report_response = await create_report(body=report_body, session=session, user=admin_user)

    # Valid change
    update_body = ReportStatusUpdateRequest(status="resolved")
    result = await update_report_status(
        report_id=report_response.id, body=update_body, session=session, user=admin_user
    )
    assert result["status"] == "resolved"

    # Invalid status should raise
    bad_body = ReportStatusUpdateRequest(status="not-a-status")
    with pytest.raises(HTTPException):
        await update_report_status(
            report_id=report_response.id, body=bad_body, session=session, user=admin_user
        )
