import ssl
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from .config import get_settings

settings = get_settings()

# Get effective DSN (supports both DATABASE_URL and POSTGRES_DSN)
postgres_dsn = settings.effective_postgres_dsn

# Configure SSL for Neon/remote databases
connect_args = {}
if "neon.tech" in postgres_dsn or "sslmode=require" in postgres_dsn or "ssl=require" in postgres_dsn or "railway.app" in postgres_dsn:
    # Create SSL context for secure connections
    ssl_context = ssl.create_default_context()
    connect_args["ssl"] = ssl_context

# Create engine with SSL support if needed
engine = create_async_engine(
    postgres_dsn,
    echo=False,
    future=True,
    connect_args=connect_args if connect_args else {},
)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)


class Base(DeclarativeBase):
    pass


async def get_session() -> AsyncSession:
    async with SessionLocal() as session:
        yield session
