# Deploy to Railway - Step by Step 🚀

## 🎯 Quick Start (5 Minutes)

Follow these exact steps to deploy your backend to Railway.

## Step 1: Open Railway Dashboard

1. **Go to:** https://railway.app/dashboard
2. **Login** (or create account if needed)
3. **You should see your project** (ID: `d83eed38-27e4-4539-bd80-431d789d0c97`)

## Step 2: Add PostgreSQL Database

1. **In your project, click the "+" button** (or "New")
2. **Select "Database"**
3. **Choose "Add PostgreSQL"**
4. **Wait for it to provision** (takes ~30 seconds)
5. **Railway automatically:**
   - Creates PostgreSQL database
   - Sets `DATABASE_URL` environment variable
   - Connects it to your project

✅ **Database is ready!**

## Step 3: Add Backend Service

**Option A: From GitHub (Recommended if you have repo)**

1. **Click "+" → "GitHub Repo"**
2. **Connect GitHub** (if not connected)
3. **Select your repository**
4. **Railway auto-detects Python/FastAPI**
5. **Auto-deploys!**

**Option B: Empty Service + Upload (No GitHub needed)**

1. **Click "+" → "Empty Service"**
2. **Name it:** `talkam-backend` (or any name)
3. **Click on the service**
4. **Go to "Settings" tab**
5. **Scroll to "Source" section**
6. **Click "Connect GitHub"** OR **"Deploy from local directory"**

**If using local directory:**
- Railway CLI needed (or use GitHub method)
- Or zip backend folder and upload

**Best: Use GitHub (even if private repo)**

## Step 4: Configure Service

1. **Click on your backend service**
2. **Go to "Settings" tab**
3. **Check these settings:**

   **Root Directory:** (leave empty or set to `backend` if repo root)
   
   **Build Command:** (auto-detected, should be empty or `pip install -e .`)
   
   **Start Command:** (should be):
   ```
   uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```

4. **If Start Command is wrong, click "Edit" and set it**

## Step 5: Set Environment Variables

1. **Still in your service, go to "Variables" tab**
2. **Click "New Variable"** for each:

   **Variable 1:**
   - Name: `JWT_SECRET`
   - Value: Generate with:
     ```bash
     python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
     ```
   - Click "Add"

   **Variable 2:**
   - Name: `CORS_ORIGINS`
   - Value: `*`
   - Click "Add"

   **Variable 3:**
   - Name: `ENVIRONMENT`
   - Value: `production`
   - Click "Add"

   **Variable 4 (if using Redis):**
   - Name: `REDIS_URL`
   - Value: (your Redis URL, or leave empty for now)

3. **Railway automatically sets:**
   - `DATABASE_URL` (from PostgreSQL service)
   - `PORT` (for the service)

✅ **Variables set!**

## Step 6: Deploy

**If using GitHub:**
- Railway auto-deploys on every push
- Or click "Redeploy" in "Deployments" tab

**If using Empty Service:**
- Click "Deploy" or push to connected repo
- Watch deployment in "Deployments" tab

**Watch the logs:**
1. Go to "Deployments" tab
2. Click on latest deployment
3. Watch "Logs" tab
4. Should see:
   - Building...
   - Installing dependencies...
   - Running migrations (from Procfile)
   - Starting server...

✅ **Deployment complete when you see:**
```
Application startup complete.
Uvicorn running on http://0.0.0.0:PORT
```

## Step 7: Get Your URL

1. **Click on your service**
2. **Go to "Settings" tab**
3. **Scroll to "Domains" section**
4. **Click "Generate Domain"**
5. **Copy the URL** (e.g., `https://talkam-api.railway.app`)

✅ **You now have your Railway URL!**

## Step 8: Verify Deployment

**Test in browser:**
```
https://YOUR-URL.railway.app/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or use the script:**
```bash
./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app
```

## Step 9: Update Mobile App

**Use the script:**
```bash
./scripts/update_railway_url.sh https://YOUR-URL.railway.app
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://YOUR-URL.railway.app/v1',
```

## Step 10: Rebuild APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:**
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

## ✅ Done!

**Your backend is now live on Railway!**

**Next:**
- Test the APK on a device
- Share APK with users
- Monitor Railway dashboard for logs/errors

## 🆘 Troubleshooting

**Deployment fails:**
- Check "Logs" tab in Railway
- Verify environment variables are set
- Check Start Command is correct

**Can't connect:**
- Verify Railway URL is correct
- Check CORS_ORIGINS is set to `*`
- Test `/health` endpoint

**Migrations not running:**
- Check `Procfile` has: `release: alembic upgrade head || true`
- Or run manually in Railway terminal

**Need help?**
- Railway docs: https://docs.railway.app
- Check logs in Railway dashboard

---

**Follow these steps and you'll be deployed in minutes!** 🚀



