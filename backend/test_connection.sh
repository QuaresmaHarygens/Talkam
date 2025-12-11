#!/bin/bash
# Test database connection

source .venv/bin/activate
export PYTHONPATH="$(pwd)"

echo "🔍 Testing database connection..."
echo ""

python3 << 'PYTHON_SCRIPT'
import asyncio
import sys
from app.database import engine
from sqlalchemy import text

async def test_connection():
    try:
        async with engine.begin() as conn:
            result = await conn.execute(text("SELECT version();"))
            version = result.scalar()
            print("✅ Database connection successful!")
            print(f"📊 PostgreSQL version: {version.split(',')[0]}")
            return True
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("")
        print("💡 Troubleshooting:")
        print("   - Check your connection string in .env")
        print("   - Verify database is accessible")
        print("   - Check network connection")
        return False

if __name__ == "__main__":
    success = asyncio.run(test_connection())
    sys.exit(0 if success else 1)
PYTHON_SCRIPT
