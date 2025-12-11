# Fresh Fly.io Setup - Complete Guide 🚀

## 🎯 Create New Fly.io App from Scratch

**This guide will help you create a brand new Fly.io app for Talkam.**

---

## Step 1: Clean Up (If Needed)

**If you want to start completely fresh:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"

# Remove old fly.toml (optional - we'll create new one)
# rm fly.toml
```

**Or keep existing and create new app with different name**

---

## Step 2: Verify Fly CLI

**Make sure Fly CLI is installed and in PATH:**

```bash
export PATH="$HOME/.fly/bin:$PATH"
fly version
```

**If not installed:**
```bash
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"
```

---

## Step 3: Login to Fly.io

**Authenticate:**

```bash
fly auth login
```

**Opens browser for authentication**

**Verify:**
```bash
fly auth whoami
```

---

## Step 4: Create New App

**Navigate to backend and create new app:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly launch --name talkam-backend --region lhr
```

**OR use interactive mode:**

```bash
fly launch
```

**When prompted:**
- **App name:** `talkam-backend` (or any unique name)
- **Region:** Choose closest (e.g., `lhr` for London, `iad` for US East)
- **PostgreSQL:** **Say "YES"** ✅ (Important!)
- **Redis:** Say "no"
- **Deploy now:** Say "no" (we'll configure first)

**This creates:**
- `fly.toml` config file
- `.dockerignore` file
- Sets up app in Fly.io

---

## Step 5: Add PostgreSQL (If Not Added)

**If you said "no" to PostgreSQL:**

```bash
# Create database
fly postgres create --name talkam-db --region lhr

# Attach to your app
fly postgres attach talkam-db
```

**Verify:**
```bash
fly secrets list
```

**Should see:** `DATABASE_URL`

---

## Step 6: Set Environment Variables (Secrets)

**Generate JWT secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Set secrets:**
```bash
fly secrets set JWT_SECRET="paste-your-generated-secret-here"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

**Your generated JWT secret:**
```
8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU
```

**View all secrets:**
```bash
fly secrets list
```

**Should show:**
- `DATABASE_URL` (auto-set)
- `JWT_SECRET`
- `CORS_ORIGINS`
- `ENVIRONMENT`

---

## Step 7: Verify Dockerfile

**Check `backend/Dockerfile` is correct:**

**Should have:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and application code
COPY pyproject.toml ./
COPY app/ ./app/
COPY alembic.ini ./
COPY alembic/ ./alembic/

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir . eval-type-backport

# Expose port
EXPOSE 8000

# Run migrations and start server
CMD ["sh", "-c", "alembic upgrade head || true && uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
```

**Important:** `app/` must be copied BEFORE `pip install .`

---

## Step 8: Verify fly.toml

**Check `backend/fly.toml`:**

**Should have:**
```toml
app = 'talkam-backend'
primary_region = 'lhr'

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = 0
  processes = ['app']

[[vm]]
  memory = '1gb'
  cpu_kind = 'shared'
  cpus = 1
```

**If port is different, update Dockerfile CMD**

---

## Step 9: Deploy

**Deploy your app:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly deploy
```

**Watch the deployment:**
- Builds Docker image
- Installs dependencies
- Deploys to Fly.io
- Shows URL when done

**If deployment fails:**
```bash
fly logs
```

---

## Step 10: Get Your URL

**After successful deployment:**

```bash
fly status
```

**Or check dashboard:** https://fly.io/dashboard

**URL format:** `https://talkam-backend.fly.dev`

---

## Step 11: Test Deployment

**Test health endpoint:**
```bash
curl https://your-app.fly.dev/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Test in browser:**
- Open: `https://your-app.fly.dev/docs`
- Should show FastAPI documentation

---

## Step 12: Update Mobile App

**Once service is working:**

```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app.fly.dev
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://your-app.fly.dev/v1',
```

---

## Step 13: Rebuild APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## ✅ Complete Checklist

- [ ] Fly CLI installed and in PATH
- [ ] Logged in to Fly.io
- [ ] Created new app (`fly launch`)
- [ ] PostgreSQL database created and attached
- [ ] Secrets set (JWT_SECRET, CORS_ORIGINS, ENVIRONMENT)
- [ ] Dockerfile verified (app/ copied before pip install)
- [ ] fly.toml configured correctly
- [ ] App deployed successfully
- [ ] Health endpoint tested
- [ ] Mobile app updated with Fly.io URL
- [ ] APK rebuilt

---

## 🆘 Troubleshooting

### Deployment Fails

**Check logs:**
```bash
fly logs
```

**Common issues:**
- Dockerfile order wrong (app/ must be before pip install)
- Missing environment variables
- Database not connected

### Database Not Connected

**Check:**
```bash
fly postgres list
fly postgres attach <db-name>
fly secrets list  # Should see DATABASE_URL
```

### App Won't Start

**Check:**
```bash
fly status
fly logs
```

**Verify:**
- Port matches fly.toml
- Environment variables are set
- Database is connected

---

## 📝 Quick Command Reference

```bash
# Setup
export PATH="$HOME/.fly/bin:$PATH"
fly auth login
cd backend
fly launch --name talkam-backend --region lhr

# Database
fly postgres create --name talkam-db --region lhr
fly postgres attach talkam-db

# Secrets
fly secrets set JWT_SECRET="your-secret"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"

# Deploy
fly deploy

# Check
fly status
fly logs
fly secrets list
```

---

## 🎯 Your Generated JWT Secret

**Use this for secrets:**
```
8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU
```

---

**Follow these steps to create a fresh Fly.io app!** 🚀
