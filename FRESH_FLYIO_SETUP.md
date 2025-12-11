# Fresh Fly.io Setup for Talkam - Step by Step 🚀

## 🎯 Clean Setup

**Setting up a new Fly.io app from scratch with proper configuration.**

---

## Step 1: Verify Fly CLI

**Check Fly CLI is installed and in PATH:**
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

## Step 2: Login to Fly.io

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

## Step 3: Create New App

**Navigate to backend:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
```

**Initialize new app:**
```bash
fly launch --no-deploy
```

**When prompted:**
- **App name:** `talkam-backend` (or any unique name)
- **Organization:** Select your personal org
- **Region:** Choose closest (e.g., `iad` for US East, `lhr` for London)
- **PostgreSQL:** **Say "yes"** ✅ (creates database)
- **Redis:** Say "no"
- **Deploy now:** Say "no" (we'll configure first)

**OR use the pre-configured fly.toml:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly apps create talkam-backend
```

---

## Step 4: Add PostgreSQL Database

**If you didn't add PostgreSQL during launch:**

```bash
# Create database
fly postgres create --name talkam-db --region iad

# Attach to your app
fly postgres attach talkam-db --app talkam-backend
```

**This automatically:**
- Sets `DATABASE_URL` environment variable
- Links database to your app

**Verify:**
```bash
fly secrets list --app talkam-backend
```

**Should see:** `DATABASE_URL`

---

## Step 5: Set Environment Variables (Secrets)

**Generate JWT secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Set secrets:**
```bash
fly secrets set JWT_SECRET="8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU" --app talkam-backend
fly secrets set CORS_ORIGINS="*" --app talkam-backend
fly secrets set ENVIRONMENT="production" --app talkam-backend
```

**View all secrets:**
```bash
fly secrets list --app talkam-backend
```

**Should show:**
- `DATABASE_URL` (auto-set)
- `JWT_SECRET`
- `CORS_ORIGINS`
- `ENVIRONMENT`

---

## Step 6: Verify Dockerfile

**Check `backend/Dockerfile` is correct:**

**Should have:**
```dockerfile
# Copy app/ BEFORE pip install
COPY pyproject.toml ./
COPY app/ ./app/
COPY alembic.ini ./
COPY alembic/ ./alembic/

# Then install
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir . eval-type-backport
```

**I've already fixed this for you!**

---

## Step 7: Verify fly.toml

**Check `backend/fly.toml`:**

**Should have:**
```toml
app = "talkam-backend"
primary_region = "iad"

[http_service]
  internal_port = 8000
```

**I've created a fresh fly.toml for you!**

---

## Step 8: Deploy

**Deploy your app:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly deploy --app talkam-backend
```

**Watch the deployment:**
- Builds Docker image
- Installs dependencies
- Deploys to Fly.io
- Shows URL when done

**If deployment fails:**
```bash
fly logs --app talkam-backend
```

---

## Step 9: Get Your URL

**After successful deployment:**

```bash
fly status --app talkam-backend
```

**Or check dashboard:** https://fly.io/dashboard

**URL format:** `https://talkam-backend.fly.dev`

---

## Step 10: Test Deployment

**Test health endpoint:**
```bash
curl https://talkam-backend.fly.dev/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Test in browser:**
- Open: `https://talkam-backend.fly.dev/docs`
- Should show FastAPI documentation

---

## Step 11: Update Mobile App

**Once service is working:**

```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://talkam-backend.fly.dev
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://talkam-backend.fly.dev/v1',
```

---

## Step 12: Rebuild APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## ✅ Complete Command Sequence

**Run these in order:**

```bash
# 1. Add to PATH
export PATH="$HOME/.fly/bin:$PATH"

# 2. Login
fly auth login

# 3. Create app
cd "/Users/visionalventure/Watch Liberia/backend"
fly apps create talkam-backend

# 4. Add PostgreSQL
fly postgres create --name talkam-db --region iad
fly postgres attach talkam-db --app talkam-backend

# 5. Set secrets
fly secrets set JWT_SECRET="8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU" --app talkam-backend
fly secrets set CORS_ORIGINS="*" --app talkam-backend
fly secrets set ENVIRONMENT="production" --app talkam-backend

# 6. Deploy
fly deploy --app talkam-backend

# 7. Get URL
fly status --app talkam-backend
```

---

## 🆘 Troubleshooting

### App Creation Fails

**If app name is taken:**
- Choose a different name
- Or use auto-generated name

### Database Creation Fails

**Check:**
```bash
fly postgres list
```

**Try different region:**
```bash
fly postgres create --name talkam-db --region lhr
```

### Deployment Fails

**Check logs:**
```bash
fly logs --app talkam-backend
```

**Common issues:**
- Dockerfile errors
- Missing dependencies
- Wrong port configuration

---

## 📝 Files Ready

**I've prepared:**
- ✅ `backend/Dockerfile` - Fixed (copies app/ before install)
- ✅ `backend/fly.toml` - Fresh configuration
- ✅ `backend/requirements.txt` - Dependencies list

---

**Follow these steps to create a fresh Fly.io app!** 🚀

