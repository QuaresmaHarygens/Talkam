# Railway Deployment Checklist ✅

## 🎯 Current Status

**Ready to Deploy:** All configuration files are prepared!

## 📋 Pre-Deployment Checklist

- [x] Railway config (`railway.json`) created
- [x] Procfile with auto-migrations created
- [x] DATABASE_URL support added to config
- [x] Helper scripts created
- [x] Documentation guides created

## 🚀 Deployment Steps

### Step 1: Open Railway Dashboard
- [ ] Go to: https://railway.app/dashboard
- [ ] Login to Railway
- [ ] Open your project

### Step 2: Add PostgreSQL
- [ ] Click "New" → "Database" → "Add PostgreSQL"
- [ ] Wait for provisioning (~30 seconds)
- [ ] Verify `DATABASE_URL` is auto-set

### Step 3: Add Backend Service

**Choose one method:**

**Option A: GitHub (Recommended)**
- [ ] Click "New" → "GitHub Repo"
- [ ] Connect GitHub account
- [ ] Select repository
- [ ] Railway auto-detects and deploys

**Option B: Empty Service**
- [ ] Click "New" → "Empty Service"
- [ ] Connect GitHub or upload files
- [ ] Configure service

### Step 4: Configure Service
- [ ] Set Root Directory (if needed)
- [ ] Verify Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- [ ] Check Build Command (auto-detected)

### Step 5: Set Environment Variables
- [ ] `JWT_SECRET` - Generate secure token
- [ ] `CORS_ORIGINS` - Set to `*`
- [ ] `ENVIRONMENT` - Set to `production`
- [ ] Verify `DATABASE_URL` is auto-set
- [ ] Verify `PORT` is auto-set

### Step 6: Deploy
- [ ] Watch deployment in "Deployments" tab
- [ ] Check logs for errors
- [ ] Verify migrations ran (from Procfile)
- [ ] Confirm server started successfully

### Step 7: Get URL
- [ ] Go to Service → Settings → Domains
- [ ] Click "Generate Domain"
- [ ] Copy Railway URL

### Step 8: Verify Deployment
- [ ] Test `/health` endpoint
- [ ] Test `/docs` endpoint
- [ ] Run: `./scripts/verify_railway_deployment.sh <URL>`

### Step 9: Update Mobile App
- [ ] Run: `./scripts/update_railway_url.sh <URL>`
- [ ] Or manually update `mobile/lib/providers.dart`

### Step 10: Rebuild APK
- [ ] `cd mobile`
- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] `flutter build apk --release`
- [ ] Test APK on device

## 📝 Notes

**Railway URL:** _________________________

**Deployment Date:** _________________________

**Issues Encountered:** _________________________

## ✅ Completion

- [ ] Backend deployed successfully
- [ ] Health endpoint working
- [ ] Mobile app updated
- [ ] APK rebuilt
- [ ] APK tested on device
- [ ] Ready to share with users

---

**Follow `RAILWAY_DEPLOY_NOW.md` for detailed instructions!**



