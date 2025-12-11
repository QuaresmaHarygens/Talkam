#!/usr/bin/env python3
"""Quick script to create test users (NGO and regular user)."""
import asyncio
import sys
from datetime import datetime
from uuid import uuid4

sys.path.insert(0, '.')

from app.database import SessionLocal
from app.models.core import User, NGO
from app.api.auth import _hash_password

async def create_test_users():
    """Create NGO and regular user."""
    async with SessionLocal() as session:
        try:
            from sqlalchemy import select
            
            # Create NGO user
            result = await session.execute(
                select(User).where(User.phone == "231770000002")
            )
            ngo_user = result.scalar_one_or_none()
            
            if not ngo_user:
                ngo_user = User(
                    id=uuid4(),
                    phone="231770000002",
                    password_hash=_hash_password("NGOPass123!"),
                    full_name="NGO Manager",
                    role="ngo",
                    created_at=datetime.utcnow(),
                )
                session.add(ngo_user)
                await session.flush()
                
                # Create NGO organization (optional - can be created separately via API)
                # NGO model doesn't have user_id, so we'll skip this for now
                print("✅ NGO user created successfully!")
                print("   Phone: 231770000002")
                print("   Password: NGOPass123!")
            else:
                print("⚠️  NGO user already exists")
            
            # Create regular user
            result = await session.execute(
                select(User).where(User.phone == "231770000003")
            )
            regular_user = result.scalar_one_or_none()
            
            if not regular_user:
                regular_user = User(
                    id=uuid4(),
                    phone="231770000003",
                    password_hash=_hash_password("UserPass123!"),
                    full_name="Test User 1",
                    role="user",
                    created_at=datetime.utcnow(),
                )
                session.add(regular_user)
                print("✅ Regular user created successfully!")
                print("   Phone: 231770000003")
                print("   Password: UserPass123!")
            else:
                print("⚠️  Regular user already exists")
            
            await session.commit()
            print("\n✅ All test users created/verified!")
            
        except Exception as e:
            await session.rollback()
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == "__main__":
    asyncio.run(create_test_users())

