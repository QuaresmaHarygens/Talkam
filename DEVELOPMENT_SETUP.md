# Development Setup Guide

Quick guide to get your development environment running.

## Current Status

✅ **Backend Environment**: Python 3.9.6, virtual environment ready
⚠️  **Docker**: Not installed (optional for local development)
⚠️  **Database**: Needs setup (see options below)

## Quick Start

### Option 1: Use Managed Services (Recommended without Docker)

1. **Set up backend environment**:
   ```bash
   cd backend
   source .venv/bin/activate
   pip install -e .[dev]
   ```

2. **Configure database** (choose one):
   
   **A. Neon (Free PostgreSQL)**:
   - Sign up at https://neon.tech
   - Create a database
   - Copy connection string to `backend/.env`:
     ```
     POSTGRES_DSN=postgresql+asyncpg://user:pass@host/dbname
     ```
   
   **B. Supabase (Free PostgreSQL)**:
   - Sign up at https://supabase.com
   - Create project
   - Copy connection string to `backend/.env`

   **C. Local PostgreSQL**:
   ```bash
   # macOS
   brew install postgresql@15
   brew services start postgresql@15
   createdb talkam
   ```

3. **Configure Redis** (choose one):
   
   **A. Upstash (Free Redis)**:
   - Sign up at https://upstash.com
   - Create Redis database
   - Copy URL to `backend/.env`:
     ```
     REDIS_URL=redis://user:pass@host:port
     ```
   
   **B. Local Redis**:
   ```bash
   # macOS
   brew install redis
   brew services start redis
   ```

4. **Configure Storage** (S3-compatible):
   
   **A. AWS S3** (requires AWS account):
   ```
   S3_ENDPOINT=https://s3.amazonaws.com
   S3_ACCESS_KEY=your-key
   S3_SECRET_KEY=your-secret
   ```
   
   **B. Local MinIO** (requires Docker):
   - Install Docker: https://docker.com/products/docker-desktop
   - Run: `docker run -d -p 9000:9000 -p 9001:9001 minio/minio server /data --console-address ":9001"`
   - Default credentials: minioadmin/minioadmin

5. **Start backend**:
   ```bash
   ./scripts/start_backend.sh
   # Or manually:
   cd backend
   source .venv/bin/activate
   uvicorn app.main:app --reload
   ```

### Option 2: Install Docker (Full Local Stack)

1. **Install Docker Desktop**:
   - macOS: https://docs.docker.com/desktop/install/mac-install/
   - Windows: https://docs.docker.com/desktop/install/windows-install/
   - Linux: https://docs.docker.com/engine/install/

2. **Start all services**:
   ```bash
   docker compose up -d postgres redis minio
   ```

3. **Run setup script**:
   ```bash
   ./scripts/start_dev.sh
   ```

4. **Start backend**:
   ```bash
   ./scripts/start_backend.sh
   ```

## Verify Setup

### Check Backend

```bash
# Health check
curl http://127.0.0.1:8000/health

# API docs
open http://127.0.0.1:8000/docs
```

### Check Database

```bash
# If using local PostgreSQL
psql -d talkam -c "SELECT version();"

# If using Docker
docker exec -it talkam_postgres psql -U talkam -d talkam -c "SELECT version();"
```

### Check Redis

```bash
# If using local Redis
redis-cli ping  # Should return PONG

# If using Docker
docker exec -it talkam_redis redis-cli ping
```

## Development Workflow

### 1. Start Services (Terminal 1)
```bash
# With Docker
docker compose up -d

# Or use managed services (configured in .env)
```

### 2. Start Backend (Terminal 2)
```bash
./scripts/start_backend.sh
```

### 3. Start Admin Dashboard (Terminal 3, Optional)
```bash
cd admin-web
npm install
npm run dev
```

### 4. Start Mobile App (Terminal 4, Optional)
```bash
cd mobile
flutter pub get
flutter run
```

## Common Issues

### Port Already in Use
```bash
# Find and kill process on port 8000
lsof -ti:8000 | xargs kill -9
```

### Database Connection Error
- Check database is running
- Verify connection string in `.env`
- Test connection: `psql "$POSTGRES_DSN"`

### Module Not Found
```bash
cd backend
source .venv/bin/activate
pip install -e .[dev]
```

## Next Steps

1. ✅ Backend environment ready
2. ⏭️ Set up database (managed or local)
3. ⏭️ Set up Redis (managed or local)
4. ⏭️ Configure storage (S3 or MinIO)
5. ⏭️ Start API server
6. ⏭️ Test endpoints

## Resources

- **Quick Start**: `QUICK_START_GUIDE.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`
- **API Docs**: http://127.0.0.1:8000/docs (after starting server)

---

**Ready to code! 🚀**
