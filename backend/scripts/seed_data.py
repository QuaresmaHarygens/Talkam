#!/usr/bin/env python3
"""
Seed data script for development and testing.
Creates sample users, reports, NGOs, and related data.
"""
import argparse
import asyncio
import sys
from datetime import datetime, timedelta
from uuid import uuid4

# Add parent directory to path
sys.path.insert(0, ".")

from app.database import SessionLocal, engine
from app.models.core import (
    User,
    Report,
    Location,
    ReportMedia,
    Verification,
    NGO,
    Comment,
)
from passlib.context import CryptContext
from sqlalchemy import text

# Use the same password context as the auth module
password_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=12)


async def seed_data(force: bool = False, skip_existing: bool = False):
    """Create seed data for development."""
    async with SessionLocal() as session:
        try:
            # Check if data already exists
            result = await session.execute(text("SELECT COUNT(*) FROM users"))
            user_count = result.scalar()
            
            if user_count > 0:
                if skip_existing:
                    print("⚠️  Database already has data. Skipping seed (--skip-existing).")
                    return
                if not force:
                    print("⚠️  Database already has data. Use --force to reseed or --skip-existing to skip.")
                    return
                
                # Clear existing data
                print("Clearing existing data (--force)...")
                await session.execute(
                    text(
                        "TRUNCATE TABLE report_media, comments, verifications, reports, users, ngos, locations, flags CASCADE"
                    )
                )
                await session.commit()
            
            print("🌱 Seeding database...")
            
            # Create sample users
            print("Creating users...")
            users = []
            
            # Admin user
            admin_user = User(
                id=uuid4(),
                phone="231770000001",
                password_hash=password_context.hash("AdminPass123!"),
                full_name="Admin User",
                role="admin",
                created_at=datetime.utcnow(),
            )
            users.append(admin_user)
            
            # NGO users
            ngo_user1 = User(
                id=uuid4(),
                phone="231770000002",
                password_hash=password_context.hash("NGOPass123!"),
                full_name="NGO Manager",
                role="ngo",
                created_at=datetime.utcnow(),
            )
            users.append(ngo_user1)
            
            # Regular users
            for i in range(3, 6):
                user = User(
                    id=uuid4(),
                    phone=f"23177000{i:04d}",
                    password_hash=password_context.hash("UserPass123!"),
                    full_name=f"Test User {i-2}",
                    role="user",
                    created_at=datetime.utcnow() - timedelta(days=i),
                )
                users.append(user)
            
            session.add_all(users)
            await session.commit()
            print(f"✅ Created {len(users)} users")
            
            # Create NGOs
            print("Creating NGOs...")
            ngos = []
            
            ngo1 = NGO(
                id=uuid4(),
                name="Liberia Infrastructure Watch",
                description="Monitoring infrastructure issues across Liberia",
                contact_phone="231770001000",
                contact_email="contact@liw.liberia.org",
                verified=True,
                user_id=ngo_user1.id,
                created_at=datetime.utcnow(),
            )
            ngos.append(ngo1)
            
            session.add_all(ngos)
            await session.commit()
            print(f"✅ Created {len(ngos)} NGOs")
            
            # Create sample reports
            print("Creating reports...")
            reports = []
            
            # Updated categories to match mobile app wireframe
            categories = ["social", "economic", "religious", "political", "health", "violence"]
            severities = ["low", "medium", "high", "critical"]
            counties = [
                "Montserrado", "Bomi", "Bong", "Nimba", "Lofa", "Margibi",
                "Grand Bassa", "Grand Gedeh", "Maryland", "Sinoe"
            ]
            statuses = ["submitted", "under-review", "verified", "rejected"]
            
            for i, user in enumerate(users[2:5]):  # Use regular users
                for j in range(3):
                    location = Location(
                        id=uuid4(),
                        latitude=6.3 + (i * 0.1) + (j * 0.05),
                        longitude=-10.8 + (i * 0.1) + (j * 0.05),
                        county=counties[i % len(counties)],
                        created_at=datetime.utcnow() - timedelta(days=j, hours=i*2),
                    )
                    session.add(location)
                    await session.flush()
                    
                    report = Report(
                        id=uuid4(),
                        user_id=user.id,
                        category=categories[j % len(categories)],
                        severity=severities[j % len(severities)],
                        summary=f"Sample report {i+1}-{j+1}: {categories[j % len(categories)].title()} issue in {counties[i % len(counties)]}",
                        details=f"Detailed description of the {categories[j % len(categories)]} issue reported by {user.full_name}. This is a test report for development purposes.",
                        status=statuses[j % len(statuses)],
                        anonymous=(j % 2 == 0),  # Mix of anonymous and non-anonymous
                        location_id=location.id,
                        ai_severity_score=0.7 + (j * 0.1) if j < 3 else None,
                        created_at=datetime.utcnow() - timedelta(days=j, hours=i*2),
                        updated_at=datetime.utcnow() - timedelta(days=j, hours=i*2),
                    )
                    reports.append(report)
            
            session.add_all(reports)
            await session.commit()
            print(f"✅ Created {len(reports)} reports")
            
            # Create some verifications
            print("Creating verifications...")
            verifications = []
            
            for report in reports[:3]:
                if report.status == "verified":
                    verification = Verification(
                        id=uuid4(),
                        report_id=report.id,
                        verified_by_id=ngo_user1.id,
                        verified_by_type="user",
                        action="confirm",
                        score=0.85,
                        comment="Verified by NGO team",
                        created_at=datetime.utcnow() - timedelta(hours=1),
                    )
                    verifications.append(verification)
            
            if verifications:
                session.add_all(verifications)
                await session.commit()
                print(f"✅ Created {len(verifications)} verifications")
            
            print("")
            print("✅ Seed data created successfully!")
            print("")
            print("📋 Created:")
            print(f"   - {len(users)} users (1 admin, 1 NGO, 3 regular)")
            print(f"   - {len(ngos)} NGOs")
            print(f"   - {len(reports)} reports")
            print(f"   - {len(verifications)} verifications")
            print("")
            print("🔐 Test Credentials:")
            print("   Admin: 231770000001 / AdminPass123!")
            print("   NGO:   231770000002 / NGOPass123!")
            print("   User:  231770000003 / UserPass123!")
            
        except Exception as e:
            await session.rollback()
            print(f"❌ Error seeding data: {e}")
            import traceback
            traceback.print_exc()
            raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed development data.")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Truncate existing data and reseed even if data is present.",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip seeding when data already exists.",
    )

    args = parser.parse_args()
    asyncio.run(seed_data(force=args.force, skip_existing=args.skip_existing))
