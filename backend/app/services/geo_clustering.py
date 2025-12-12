"""Geo-location clustering service for community challenges."""
from __future__ import annotations

import math
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.challenges import CommunityChallenge


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great circle distance between two points on Earth.
    Returns distance in kilometers.
    """
    # Radius of Earth in kilometers
    R = 6371.0
    
    # Convert latitude and longitude from degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Haversine formula
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(lat1_rad)
        * math.cos(lat2_rad)
        * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c


async def get_challenges_in_radius(
    session: AsyncSession,
    latitude: float,
    longitude: float,
    radius_km: float = 5.0,
    category: Optional[str] = None,
    status: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
) -> list[CommunityChallenge]:
    """
    Get challenges within a specified radius (in kilometers) from a point.
    Uses a bounding box approximation for initial filtering, then calculates
    exact distance for final results.
    """
    # Approximate bounding box (rough estimate: 1 degree ≈ 111 km)
    # This is a quick filter before exact distance calculation
    lat_delta = radius_km / 111.0
    lon_delta = radius_km / (111.0 * math.cos(math.radians(latitude)))
    
    stmt = select(CommunityChallenge).where(
        CommunityChallenge.latitude.between(latitude - lat_delta, latitude + lat_delta),
        CommunityChallenge.longitude.between(longitude - lon_delta, longitude + lon_delta),
    )
    
    if category:
        from ..models.challenges import ChallengeCategory
        stmt = stmt.where(CommunityChallenge.category == ChallengeCategory(category))
    
    if status:
        from ..models.challenges import ChallengeStatus
        stmt = stmt.where(CommunityChallenge.status == ChallengeStatus(status))
    
    stmt = stmt.limit(limit).offset(offset)
    
    result = await session.execute(stmt)
    challenges = result.scalars().all()
    
    # Filter by exact distance
    filtered_challenges = []
    for challenge in challenges:
        distance = haversine_distance(
            latitude, longitude,
            float(challenge.latitude), float(challenge.longitude)
        )
        if distance <= radius_km:
            filtered_challenges.append(challenge)
    
    return filtered_challenges


async def get_challenges_count_in_radius(
    session: AsyncSession,
    latitude: float,
    longitude: float,
    radius_km: float = 5.0,
    category: Optional[str] = None,
    status: Optional[str] = None,
) -> int:
    """Get count of challenges within radius."""
    challenges = await get_challenges_in_radius(
        session, latitude, longitude, radius_km, category, status, limit=1000
    )
    return len(challenges)
