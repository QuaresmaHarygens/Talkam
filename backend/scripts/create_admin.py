#!/usr/bin/env python3
"""Quick script to create admin user."""
import asyncio
import sys
from datetime import datetime
from uuid import uuid4

sys.path.insert(0, '.')

from app.database import SessionLocal
from app.models.core import User
from app.api.auth import password_context, _hash_password

async def create_admin():
    """Create admin user."""
    async with SessionLocal() as session:
        try:
            # Check if admin already exists
            from sqlalchemy import select
            result = await session.execute(
                select(User).where(User.phone == "231770000001")
            )
            existing = result.scalar_one_or_none()
            
            if existing:
                print("✅ Admin user already exists!")
                return
            
            # Create admin user
            admin_user = User(
                id=uuid4(),
                phone="231770000001",
                password_hash=_hash_password("AdminPass123!"),
                full_name="Admin User",
                role="admin",
                created_at=datetime.utcnow(),
            )
            session.add(admin_user)
            await session.commit()
            print("✅ Admin user created successfully!")
            print("   Phone: 231770000001")
            print("   Password: AdminPass123!")
            
        except Exception as e:
            await session.rollback()
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == "__main__":
    asyncio.run(create_admin())















