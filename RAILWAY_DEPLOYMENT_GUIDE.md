# Railway Deployment - Complete Guide 🚀

## 🎯 Goal

**Deploy backend to Railway so remote users can use APK without any network setup!**

## ✅ Step-by-Step Deployment

### Step 1: Install Railway CLI

```bash
brew install railway
```

**Verify:**
```bash
railway --version
```

### Step 2: Login to Railway

```bash
railway login
```

**This opens browser for authentication.**

### Step 3: Create New Project

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
railway init
```

**Follow prompts:**
- Create new project: Yes
- Project name: `talkam-liberia-api` (or your choice)

### Step 4: Add PostgreSQL Database

**Railway provides free PostgreSQL:**

```bash
railway add postgresql
```

**This automatically:**
- Creates PostgreSQL database
- Sets `DATABASE_URL` environment variable
- No configuration needed!

### Step 5: Set Environment Variables

**Set required environment variables:**

```bash
# JWT Secret (generate a random string)
railway variables set JWT_SECRET="your-random-secret-key-here-min-32-chars"

# CORS (allow all origins for mobile app)
railway variables set CORS_ORIGINS="*"

# Optional: Other variables
railway variables set ENVIRONMENT="production"
```

**Generate JWT Secret:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Step 6: Create Railway Configuration

**Create `railway.json` in backend folder:**

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Step 7: Create Procfile (Alternative)

**Or create `Procfile` in backend folder:**

```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### Step 8: Deploy

```bash
railway up
```

**Railway will:**
- Build your app
- Install dependencies
- Run migrations (if configured)
- Deploy to cloud
- Provide URL

### Step 9: Get Your URL

**After deployment, Railway shows your URL:**

```bash
railway domain
```

**Or check Railway dashboard:**
- Go to: https://railway.app/dashboard
- Click your project
- See URL: `https://your-app.railway.app`

### Step 10: Run Database Migrations

**Run Alembic migrations on Railway:**

```bash
railway run alembic upgrade head
```

**Or add to deployment:**
```bash
railway variables set MIGRATE_ON_DEPLOY="true"
```

### Step 11: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://your-app.railway.app/v1',  // Your Railway URL
));
```

### Step 12: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

### Step 13: Share APK!

**Now you can share the APK with anyone:**
- Works from anywhere
- No network setup needed
- Permanent URL
- Professional solution

## 🔧 Required Files

### Create `railway.json` (in backend folder):

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Or create `Procfile`:

```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
release: alembic upgrade head
```

## 📋 Environment Variables Checklist

**Set these in Railway dashboard or via CLI:**

- [ ] `DATABASE_URL` (auto-set by Railway PostgreSQL)
- [ ] `JWT_SECRET` (generate random 32+ char string)
- [ ] `CORS_ORIGINS` (set to `*` for mobile app)
- [ ] `ENVIRONMENT` (set to `production`)
- [ ] Optional: S3 credentials for media storage
- [ ] Optional: SMS gateway credentials
- [ ] Optional: Sentry DSN for error tracking

## 🔍 Verify Deployment

**Test your deployed backend:**

```bash
# Get your Railway URL
railway domain

# Test health endpoint
curl https://your-app.railway.app/health

# Should return: {"status":"healthy","service":"talkam-api"}
```

## 📱 After Deployment

### Update App

1. **Get Railway URL:** `https://your-app.railway.app`
2. **Update:** `mobile/lib/providers.dart` with Railway URL
3. **Rebuild APK**
4. **Test APK** - should work from anywhere!

### Share APK

**Now you can:**
- Share APK via email, cloud storage, etc.
- Remote users can install and use immediately
- No network configuration needed
- Works from anywhere in the world!

## ✅ Advantages

- ✅ **Permanent URL** - doesn't change
- ✅ **HTTPS** - secure by default
- ✅ **Free tier** - 500 hours/month
- ✅ **Database included** - PostgreSQL provided
- ✅ **Auto-scaling** - handles traffic
- ✅ **Professional** - production-ready

## 🎯 Quick Command Summary

```bash
# 1. Install
brew install railway

# 2. Login
railway login

# 3. Initialize
cd backend
railway init

# 4. Add database
railway add postgresql

# 5. Set variables
railway variables set JWT_SECRET="your-secret"
railway variables set CORS_ORIGINS="*"

# 6. Deploy
railway up

# 7. Get URL
railway domain

# 8. Run migrations
railway run alembic upgrade head
```

---

**Railway is the easiest way to deploy - try it now!** 🚀



