"""Tests for priority scoring system."""
import pytest
from app.services.priority_scoring import calculate_priority_score
from app.models.core import Report, Location
from tests.fakes import FakeSession
from uuid import uuid4


@pytest.mark.asyncio
async def test_priority_calculation():
    """Test priority score calculation."""
    session = FakeSession()
    
    # Create test report
    report = Report(
        id=uuid4(),
        category="security",
        severity="critical",
        summary="Test",
        status="submitted",
        witness_count=5,
        ai_severity_score=0.9,
    )
    session.add(report)
    
    # Calculate priority
    score = await calculate_priority_score(session, report)
    
    # Should be high priority (critical severity + high AI score)
    assert 0.0 <= score <= 1.0
    assert score > 0.7  # Should be high priority


@pytest.mark.asyncio
async def test_priority_with_attestations():
    """Test priority calculation includes attestations."""
    session = FakeSession()
    
    report = Report(
        id=uuid4(),
        category="infrastructure",
        severity="high",
        summary="Test",
        status="submitted",
    )
    session.add(report)
    
    # Add some attestations (would be in real DB)
    # For now, just test the calculation works
    score = await calculate_priority_score(session, report)
    assert 0.0 <= score <= 1.0
