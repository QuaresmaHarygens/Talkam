# Talkam Liberia Backend

Steps to stand up the FastAPI service locally.

## 1. Create virtual environment
```sh
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install .
```

## 2. Configure environment
```sh
cp .env.example .env
# update SECRET_KEY, POSTGRES_DSN, REDIS_URL, S3 creds, etc.
```

## 3. Apply database schema
Use whichever option suits your setup:
- Containers: `docker compose up postgres ...` (schema auto-applied) or `make init-db`.
- Dockerless: follow `artifacts/docs/dockerless-stack.md` then run `scripts/init_db.sh`.
- Alembic migrations (recommended for iterative changes; run on an empty database):
  ```sh
  source .venv/bin/activate
  export PYTHONPATH=$(pwd)
  alembic upgrade head
  ```

## 4. Run the API server
```sh
source .venv/bin/activate
uvicorn app.main:app --reload
```
Open http://127.0.0.1:8000/v1/docs to exercise endpoints.

## 5. Tests
```sh
source .venv/bin/activate
pytest
```
Pytests rely on `tests/fakes.py` to emulate the DB layer, covering auth + report flows without touching Postgres.

## Features Implemented

### Media Upload
- `POST /v1/media/upload` - Generate presigned S3 URLs for direct client uploads
- Supports photo, video, and audio types
- Configured via `S3_ENDPOINT`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` in `.env`

### Offline Sync
- `POST /v1/reports/sync` - Sync reports queued offline
- Clients send `offline_references` to confirm successful uploads
- Returns synced report IDs and pending count

### SMS Ingestion
- `POST /v1/sms/ingest` - Ingest reports submitted via SMS gateway
- Parses SMS format: `CAT=category;LOC=county;MSG=summary`
- Requires `X-SMS-Token` header matching `SMS_GATEWAY_TOKEN` from `.env`

### Verification & Alerts
- `POST /v1/reports/{id}/verify` - Community witness verification with threshold-based status updates
- `POST /v1/alerts/broadcast` - Geofenced alert broadcasting (push + SMS)

### Dashboards & Analytics
- `GET /v1/dashboards/analytics` - KPI metrics, county breakdown, category trends (NGO/Gov/Admin only)
- `GET /v1/ngos/{id}/dashboard` - NGO dashboard with filters (county, category, status)
- `GET /v1/ngos/{id}/export` - Export dashboard data (CSV/PDF)

## CI/CD

### GitHub Actions
The repository includes `.github/workflows/ci.yml` that runs on push/PR:
- Linting with `ruff`
- Tests with `pytest` + coverage
- PostgreSQL service container for integration tests

### Deployment
Use `scripts/deploy.sh [environment]` to:
1. Build Docker image (if using containers)
2. Run Alembic migrations
3. Run test suite
4. Deploy to target environment

### Docker
A `Dockerfile` is provided in `backend/` for containerized deployments.
