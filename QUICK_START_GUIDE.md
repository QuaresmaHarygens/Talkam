# Talkam Liberia - Quick Start Guide

Complete guide to get the Talkam Liberia system up and running in 15 minutes.

## Prerequisites

### Required
- **Python 3.9+** - For backend API
- **PostgreSQL 15+** - Database (local or managed)
- **Redis** - Caching and job queue (local or managed)
- **Git** - Version control

### Optional
- **Docker & Docker Compose** - For local services
- **Node.js 18+** - For admin dashboard
- **Flutter SDK** - For mobile app development
- **AWS CLI** - For infrastructure deployment

## Quick Setup (5 Minutes)

### Option 1: Docker Compose (Recommended for Development)

```bash
# 1. Clone repository
git clone <repository-url>
cd "Watch Liberia"

# 2. Start infrastructure services
docker compose up -d postgres redis minio rabbitmq

# 3. Setup backend
cd backend
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e .[dev]
cp .env.example .env
# Edit .env with your settings (or use defaults for local)

# 4. Initialize database
alembic upgrade head

# 5. Start API server
uvicorn app.main:app --reload
```

**API will be available at:** http://127.0.0.1:8000
**API Documentation:** http://127.0.0.1:8000/docs

### Option 2: Managed Services (Production-like)

```bash
# 1. Setup backend
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .[dev]

# 2. Configure .env with managed services
cp .env.example .env
# Edit .env with:
# - Neon/Upstash Postgres DSN
# - Upstash Redis URL
# - S3-compatible storage

# 3. Initialize database
alembic upgrade head

# 4. Start API server
uvicorn app.main:app --reload
```

## Environment Configuration

### Backend (.env)

```bash
# Application
APP_NAME="Talkam Liberia API"
SECRET_KEY="your-secret-key-here"  # Generate with: openssl rand -hex 32

# Database
POSTGRES_DSN="postgresql+asyncpg://user:pass@localhost:5432/talkam"

# Redis
REDIS_URL="redis://localhost:6379/0"

# Storage (S3-compatible)
S3_ENDPOINT="http://localhost:9000"  # MinIO for local
S3_ACCESS_KEY="minioadmin"
S3_SECRET_KEY="minioadmin"
BUCKET_REPORTS="talkam-media"

# Optional: SMS Gateway
SMS_GATEWAY_URL=""
SMS_GATEWAY_TOKEN=""

# Optional: Sentry
ENABLE_SENTRY=false
SENTRY_DSN=""
```

### Admin Dashboard (.env)

```bash
VITE_API_URL=http://127.0.0.1:8000/v1
```

## Testing the Setup

### 1. Health Check

```bash
curl http://127.0.0.1:8000/health
# Expected: {"status":"healthy","service":"talkam-api"}
```

### 2. API Documentation

Open browser: http://127.0.0.1:8000/docs

### 3. Create Test User

```bash
curl -X POST http://127.0.0.1:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "231770000001",
    "password": "TestPass123!",
    "full_name": "Test User"
  }'
```

### 4. Login

```bash
curl -X POST http://127.0.0.1:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "231770000001",
    "password": "TestPass123!"
  }'
```

Save the `access_token` from the response.

### 5. Create Test Report

```bash
TOKEN="your-access-token-here"

curl -X POST http://127.0.0.1:8000/v1/reports/create \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "category": "infrastructure",
    "severity": "medium",
    "summary": "Test report from quick start guide",
    "location": {
      "latitude": 6.3,
      "longitude": -10.8,
      "county": "Montserrado"
    }
  }'
```

## Running Tests

```bash
cd backend
source .venv/bin/activate
pytest -v
```

## Development Workflow

### Starting Services

```bash
# Terminal 1: Infrastructure
docker compose up -d

# Terminal 2: Backend API
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload

# Terminal 3: Admin Dashboard (optional)
cd admin-web
npm run dev
```

### Database Migrations

```bash
cd backend
source .venv/bin/activate

# Create new migration
./scripts/migrate.sh revision "Add new feature"

# Apply migrations
./scripts/migrate.sh upgrade

# Rollback
./scripts/migrate.sh downgrade -1
```

### Database Backups

```bash
cd backend
./scripts/backup_db.sh
```

## Mobile App Setup

### Prerequisites
1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Install Android Studio or Xcode (for iOS)

### Setup

```bash
cd mobile

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

### Configuration

Update API endpoint in `mobile/lib/providers.dart`:
```dart
final apiBaseUrl = 'http://127.0.0.1:8000/v1';  // Local
// final apiBaseUrl = 'https://api.talkam.liberia.com/v1';  // Production
```

## Admin Dashboard Setup

```bash
cd admin-web

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

Dashboard will be available at: http://localhost:3000

## Common Issues

### Port Already in Use

```bash
# Find and kill process on port 8000
lsof -ti:8000 | xargs kill -9
```

### Database Connection Error

1. Check PostgreSQL is running: `docker ps` or `pg_isready`
2. Verify DSN in `.env`
3. Check network connectivity

### Redis Connection Error

1. Check Redis is running: `docker ps` or `redis-cli ping`
2. Verify REDIS_URL in `.env`

### Migration Errors

```bash
# Reset database (WARNING: Deletes all data)
docker compose down -v
docker compose up -d postgres
alembic upgrade head
```

## Next Steps

1. **Read Documentation**
   - `README.md` - Main project documentation
   - `artifacts/docs/` - Detailed guides

2. **Explore API**
   - Visit http://127.0.0.1:8000/docs
   - Try all endpoints

3. **Review Architecture**
   - `artifacts/architecture/architecture.md`
   - Architecture diagrams

4. **Deploy to Production**
   - `artifacts/pilot-launch/deployment-checklist.md`
   - Infrastructure setup guides

## Getting Help

- **Documentation**: See `README.md` and `artifacts/docs/`
- **API Docs**: http://127.0.0.1:8000/docs
- **Issues**: Check `TROUBLESHOOTING.md`

## Production Deployment

For production deployment, see:
- `artifacts/pilot-launch/deployment-checklist.md`
- `infrastructure/README.md`
- `artifacts/docs/devops-plan.md`

---

**You're all set! Happy coding! 🚀**
