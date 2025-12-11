# Dockerless Local Stack Options

This guide provides alternatives to Docker for engineers who prefer native or managed services when developing Talkam Liberia.

## 1. Managed Cloud Sandbox (Recommended)
Use hosted free tiers so your laptop only runs the FastAPI + Flutter apps.

| Service | Suggested Provider | Notes |
| --- | --- | --- |
| PostgreSQL | Neon.tech / Supabase | Enable pgcrypto + PostGIS extensions. Copy the connection string into `.env`. |
| Redis Cache | Upstash | Configure TLS URL + token, set `REDIS_URL`. |
| Object Storage | AWS S3 (sandbox bucket) or MinIO Play | Create IAM user with limited permissions; store credentials in `.env`. |
| Queue | CloudAMQP (RabbitMQ) or Upstash Q | Used for media processing + notifications. |

Steps:
1. Provision sandbox instances.
2. Store credentials in `.env` (see template in `backend/.env.example`).
3. Run migrations with `alembic upgrade head` pointing to Neon/Supabase.
4. Launch FastAPI locally with `uvicorn app.main:app --reload`.

## 2. Native macOS/Linux Services
Install services directly on the host using package managers.

### PostgreSQL
- macOS: `brew install postgresql@15 && brew services start postgresql@15`
- Linux: use apt (`sudo apt install postgresql-15 postgresql-contrib`).
- Run `psql -d postgres` and create the `talkam` DB: `CREATE DATABASE talkam;`.
- Apply schema: `psql -d talkam -f artifacts/data/schema.sql`.

### Redis
- macOS: `brew install redis && brew services start redis`.
- Linux: `sudo apt install redis-server` and enable `supervised systemd` in `/etc/redis/redis.conf`.

### MinIO / S3 Alternative
- Use `pipx install s3server` or `brew install minio` and run `minio server ~/Minio --console-address :9001`.

### RabbitMQ
- macOS: `brew install rabbitmq` then `brew services start rabbitmq`.
- Linux: follow instructions at https://www.rabbitmq.com/install-debian.html.

### Mailhog Replacement
- `brew install mailhog && mailhog` or use `go install github.com/mailhog/MailHog@latest`.

## 3. Lightweight VM (Colima / Podman)
If Docker Desktop is the only blocker, run containers via Colima + nerdctl or Podman. The existing `docker-compose.yml` works by replacing `docker` with `podman` or using `colima start --edit` with Docker API compatibility.

## Verification Checklist
- `psql -h localhost -U <user> -d talkam -c "SELECT now();"`
- `redis-cli ping`
- `rabbitmqctl status`
- Upload test file to MinIO via `mc alias set local http://127.0.0.1:9000 talkam talkamsecret`.

Document the chosen option in your team runbook so others can reproduce the setup.
