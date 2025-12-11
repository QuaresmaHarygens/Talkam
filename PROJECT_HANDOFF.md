# Talkam Liberia - Project Handoff Document

Complete handoff documentation for developers and stakeholders.

## Project Overview

**Talkam Liberia** is a comprehensive social reporting system designed for Liberia, enabling citizens to report issues, concerns, and emergencies through a mobile-first platform with strong emphasis on user safety, anonymity, and offline capabilities.

## System Architecture

### Components

1. **Backend API** (FastAPI + PostgreSQL)
   - RESTful API with 20+ endpoints
   - PostgreSQL database with complete schema
   - Redis for caching and rate limiting
   - S3-compatible storage for media
   - JWT authentication (user & anonymous)

2. **Mobile App** (Flutter)
   - iOS and Android support
   - Offline-first with sync capability
   - Location services integration
   - Media capture and upload
   - Interactive map view

3. **Admin Dashboard** (React + TypeScript)
   - Analytics and KPIs
   - Report management and verification
   - Alert broadcasting
   - User management

4. **Infrastructure** (Terraform + Kubernetes)
   - AWS/GCP/Azure ready
   - Auto-scaling configurations
   - Security groups and networking
   - Monitoring and alerting

## Project Structure

```
Watch Liberia/
├── backend/              # FastAPI backend application
│   ├── app/             # Application code
│   │   ├── api/         # API endpoints
│   │   ├── models/      # Database models
│   │   ├── schemas/     # Pydantic schemas
│   │   ├── services/    # Business logic
│   │   └── middleware.py # Rate limiting, security
│   ├── tests/           # Unit and integration tests
│   ├── alembic/         # Database migrations
│   └── scripts/         # Operational scripts
│
├── mobile/              # Flutter mobile application
│   └── lib/             # Dart source code
│
├── admin-web/           # React admin dashboard
│   └── src/             # React source code
│
├── infrastructure/      # Infrastructure as Code
│   ├── terraform/       # Terraform configurations
│   └── kubernetes/      # Kubernetes manifests
│
├── monitoring/          # Monitoring setup
│   ├── prometheus/      # Prometheus config
│   └── grafana/         # Grafana config
│
├── scripts/             # Utility scripts
│   ├── load-testing/    # Load testing tools
│   └── dev-tools/       # Development helpers
│
└── artifacts/           # Documentation and specs
    ├── architecture/    # Architecture docs
    ├── docs/            # Technical guides
    ├── pilot-launch/    # Launch materials
    └── specs/           # API specifications
```

## Key Features

### User Features
- ✅ Anonymous and registered user accounts
- ✅ Report creation with media (photo, video, audio)
- ✅ Location tagging
- ✅ Offline report submission
- ✅ SMS-based reporting
- ✅ Interactive map view
- ✅ Report verification system

### Admin Features
- ✅ Analytics dashboard
- ✅ Report verification workflow
- ✅ Alert broadcasting (SMS + Push)
- ✅ User management
- ✅ Category and county filtering

### Technical Features
- ✅ Rate limiting
- ✅ Health checks
- ✅ Error tracking (Sentry ready)
- ✅ API documentation (Swagger/ReDoc)
- ✅ Database migrations
- ✅ Backup and restore scripts
- ✅ Load testing tools

## Getting Started

### Quick Start (5 minutes)

See `QUICK_START_GUIDE.md` for detailed instructions.

1. Start infrastructure: `docker compose up -d`
2. Setup backend: `cd backend && pip install -e .[dev]`
3. Initialize database: `alembic upgrade head`
4. Start API: `uvicorn app.main:app --reload`
5. Access docs: http://localhost:8000/docs

### Development Setup

Run the automated setup script:
```bash
./scripts/dev-tools/setup_dev.sh
```

## Configuration

### Backend Environment Variables

Key configuration variables (see `.env.example.commented` for full details):

- `SECRET_KEY` - JWT signing key (MUST change in production)
- `POSTGRES_DSN` - Database connection string
- `REDIS_URL` - Redis connection URL
- `S3_ENDPOINT` - S3-compatible storage endpoint
- `SMS_GATEWAY_URL` - SMS provider API endpoint
- `SENTRY_DSN` - Error tracking (optional)

### Mobile App Configuration

Update API endpoint in `mobile/lib/providers.dart`:
```dart
final apiBaseUrl = 'http://127.0.0.1:8000/v1';  // Local
```

### Admin Dashboard Configuration

Set API URL in `admin-web/.env`:
```
VITE_API_URL=http://127.0.0.1:8000/v1
```

## Development Workflow

### Backend Development

1. **Start Services**
   ```bash
   docker compose up -d
   ```

2. **Run Migrations**
   ```bash
   cd backend
   ./scripts/migrate.sh upgrade
   ```

3. **Run Tests**
   ```bash
   pytest -v
   ```

4. **Start API Server**
   ```bash
   uvicorn app.main:app --reload
   ```

### Database Operations

```bash
# Create migration
./scripts/migrate.sh revision "Description"

# Apply migrations
./scripts/migrate.sh upgrade

# Rollback
./scripts/migrate.sh downgrade -1

# Backup
./scripts/backup_db.sh

# Restore
./scripts/restore_db.sh backups/backup.sql.gz
```

### Mobile App Development

```bash
cd mobile
flutter pub get
flutter run
```

## Testing

### Backend Tests

```bash
cd backend
pytest -v                    # Run all tests
pytest -v tests/test_auth.py # Run specific test file
pytest --cov=app             # With coverage
```

### Load Testing

```bash
cd scripts/load-testing
pip install -r requirements.txt
python load_test.py http://127.0.0.1:8000 10 60
```

### Integration Testing

All API endpoints are tested. See `backend/tests/` for test suite.

## Deployment

### Infrastructure Deployment

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

### Backend Deployment

```bash
# Build Docker image
docker build -t talkam-backend:latest .

# Deploy to Kubernetes
kubectl apply -f infrastructure/kubernetes/
```

### Admin Dashboard Deployment

```bash
cd admin-web
npm run build
# Deploy dist/ to Vercel, Netlify, or S3
```

See `artifacts/pilot-launch/deployment-checklist.md` for complete deployment guide.

## Monitoring

### Health Checks

- Basic: `GET /health`
- Database: `GET /health/db`
- Redis: `GET /health/redis`
- Storage: `GET /health/storage`
- Full: `GET /health/full`

### Prometheus Metrics

Access Prometheus at http://localhost:9090
Access Grafana at http://localhost:3001

### Error Tracking

Configure Sentry in `.env`:
```
ENABLE_SENTRY=true
SENTRY_DSN=https://your-dsn@sentry.io/project-id
```

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/v1/openapi.json

## Security Considerations

1. **Secrets Management**
   - Never commit `.env` files
   - Use secrets management service in production (AWS Secrets Manager, etc.)
   - Rotate SECRET_KEY regularly

2. **Authentication**
   - JWT tokens with expiration
   - Refresh token mechanism
   - Anonymous access with device hash

3. **Data Protection**
   - Encryption at rest (database, storage)
   - Encryption in transit (HTTPS/TLS)
   - Face blur and voice masking for media

4. **Rate Limiting**
   - Redis-based rate limiting
   - Configurable limits per endpoint
   - Graceful degradation

## Troubleshooting

See `TROUBLESHOOTING.md` for common issues and solutions.

Common issues:
- Database connection errors
- Redis connection errors
- Port conflicts
- Migration errors
- API authentication issues

## Key Documentation

- `README.md` - Main project documentation
- `QUICK_START_GUIDE.md` - Quick setup guide
- `TROUBLESHOOTING.md` - Common issues and solutions
- `PRODUCTION_READY_SUMMARY.md` - System completeness overview
- `OPERATIONAL_ENHANCEMENTS.md` - Operational features
- `artifacts/pilot-launch/` - Launch materials
- `artifacts/docs/` - Technical documentation

## Next Steps

1. **Development**
   - Review codebase structure
   - Set up development environment
   - Run tests and verify setup

2. **Configuration**
   - Configure environment variables
   - Set up local services
   - Test all endpoints

3. **Deployment Preparation**
   - Review deployment checklist
   - Set up production infrastructure
   - Configure monitoring

4. **Pilot Launch**
   - Review pilot launch plan
   - Prepare user materials
   - Set up support channels

## Support and Maintenance

### Code Maintenance

- Follow existing code style (Ruff linting)
- Write tests for new features
- Update documentation
- Follow Git workflow (feature branches, PRs)

### Database Maintenance

- Regular backups (daily recommended)
- Monitor database size
- Review slow queries
- Update indexes as needed

### Infrastructure Maintenance

- Monitor resource usage
- Review security groups
- Update dependencies regularly
- Review and update Terraform configs

## Contact and Resources

- **Documentation**: See `artifacts/docs/`
- **API Docs**: http://localhost:8000/docs
- **Architecture**: `artifacts/architecture/architecture.md`

## Project Status

**Status**: ✅ Production Ready

- ✅ Backend API: Complete
- ✅ Mobile App: Complete (needs Flutter SDK)
- ✅ Admin Dashboard: Complete
- ✅ Infrastructure: Complete
- ✅ Documentation: Complete
- ✅ Operational Tools: Complete

**Ready for**: Pilot launch and production deployment

---

**Welcome to the Talkam Liberia project! 🚀**
