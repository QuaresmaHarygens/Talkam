# Deploy to Railway - Step by Step Guide 🚀

## 🎯 Let's Deploy Right Now!

Follow these exact steps. I'll guide you through each one.

---

## STEP 1: Open Railway Dashboard

1. **Open your browser**
2. **Go to:** https://railway.app/dashboard
3. **Login** (or create account if needed)
4. **You should see your project** or create a new one

**✅ Action:** Open Railway dashboard now

---

## STEP 2: Add PostgreSQL Database

1. **In your Railway project, look for a "+" button** (usually top right or in the project view)
2. **Click the "+" button**
3. **Select "Database"** from the menu
4. **Choose "Add PostgreSQL"**
5. **Wait 30-60 seconds** for Railway to provision the database
6. **You'll see a new PostgreSQL service appear**

**What happens:**
- Railway creates a PostgreSQL database
- Automatically sets `DATABASE_URL` environment variable
- Connects it to your project

**✅ Action:** Add PostgreSQL database in Railway

**📝 Note:** Write down when this is done before moving to next step

---

## STEP 3: Add Backend Service

**You have 2 options. Choose the easiest for you:**

### Option A: GitHub Repo (Recommended - Easiest)

**If you have a GitHub account:**

1. **In Railway, click "+" button again**
2. **Select "GitHub Repo"**
3. **Connect your GitHub account** (if not connected)
4. **Select your repository** (or create one first)
5. **Railway will:**
   - Auto-detect Python/FastAPI
   - Use your `railway.json` and `Procfile`
   - Start deploying automatically

**✅ Action:** Connect GitHub repo OR use Option B

### Option B: Empty Service (No GitHub needed)

1. **In Railway, click "+" button**
2. **Select "Empty Service"**
3. **Name it:** `talkam-backend`
4. **Click on the service** to open it
5. **Go to "Settings" tab**
6. **Scroll to "Source" section**
7. **You can:**
   - Connect a GitHub repo here, OR
   - Use Railway CLI (if installed), OR
   - Upload files manually

**✅ Action:** Create Empty Service OR connect GitHub repo

**📝 Note:** GitHub method is easier - Railway auto-deploys on every push

---

## STEP 4: Configure Service Settings

1. **Click on your backend service** (the one you just created)
2. **Go to "Settings" tab**
3. **Check these settings:**

   **Root Directory:**
   - If your repo root is the project root: Leave empty
   - If `backend/` folder is at repo root: Set to `backend`
   - **Most likely:** Leave empty if `backend/` is the repo root

   **Build Command:**
   - Should be auto-detected
   - If empty, that's fine (Railway uses `pyproject.toml`)

   **Start Command:**
   - Should be: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - If different, click "Edit" and set it to this

**✅ Action:** Verify Start Command is correct

---

## STEP 5: Set Environment Variables

**This is critical! Do this step carefully.**

1. **Still in your service, go to "Variables" tab**
2. **You'll see some variables already set:**
   - `DATABASE_URL` (auto-set by PostgreSQL service)
   - `PORT` (auto-set by Railway)

3. **Click "New Variable" button**

4. **Add Variable 1:**
   - **Name:** `JWT_SECRET`
   - **Value:** Generate one now:
     ```bash
     python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
     ```
     Copy the output and paste as the value
   - **Click "Add"**

5. **Add Variable 2:**
   - **Name:** `CORS_ORIGINS`
   - **Value:** `*`
   - **Click "Add"**

6. **Add Variable 3:**
   - **Name:** `ENVIRONMENT`
   - **Value:** `production`
   - **Click "Add"**

7. **Add Variable 4 (if you have Redis):**
   - **Name:** `REDIS_URL`
   - **Value:** (your Redis URL, or leave empty for now)
   - **Click "Add"**

**✅ Action:** Set all 3 required variables (JWT_SECRET, CORS_ORIGINS, ENVIRONMENT)

**📝 Checklist:**
- [ ] JWT_SECRET set (long random string)
- [ ] CORS_ORIGINS set to `*`
- [ ] ENVIRONMENT set to `production`
- [ ] DATABASE_URL is visible (auto-set)

---

## STEP 6: Deploy

**If using GitHub:**
- Railway auto-deploys when you push
- Or click "Redeploy" in "Deployments" tab

**If using Empty Service:**
- Push to connected repo, OR
- Click "Deploy" button

**Watch the deployment:**

1. **Go to "Deployments" tab**
2. **Click on the latest deployment**
3. **Watch the "Logs" tab**
4. **You should see:**
   ```
   Building...
   Installing dependencies...
   Running migrations...
   Starting server...
   Application startup complete.
   Uvicorn running on http://0.0.0.0:PORT
   ```

**✅ Action:** Watch deployment logs until you see "Application startup complete"

**⚠️ If you see errors:**
- Check the error message
- Common issues:
  - Missing environment variables
  - Wrong Start Command
  - Build errors (check Python version)

---

## STEP 7: Get Your Railway URL

1. **Click on your service** (if not already there)
2. **Go to "Settings" tab**
3. **Scroll down to "Domains" section**
4. **Click "Generate Domain" button**
5. **Railway generates a URL** like: `https://talkam-api.railway.app`
6. **Copy the URL**

**✅ Action:** Generate domain and copy the URL

**📝 Write down your URL:** _________________________

---

## STEP 8: Verify Deployment

**Test your deployed backend:**

1. **Open a new browser tab**
2. **Go to:** `https://YOUR-URL.railway.app/health`
3. **You should see:**
   ```json
   {"status":"healthy","service":"talkam-api"}
   ```

**Or use the script:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app
```

**✅ Action:** Test the health endpoint

**📝 Result:** [ ] Health check passed / [ ] Health check failed

---

## STEP 9: Update Mobile App

**Now update your mobile app to use the Railway URL:**

**Option A: Use Script (Easiest)**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://YOUR-URL.railway.app
```

**Option B: Manual Update**
1. **Edit:** `mobile/lib/providers.dart`
2. **Find:** `baseUrl: 'https://...'`
3. **Replace with:** `baseUrl: 'https://YOUR-URL.railway.app/v1'`
4. **Save file**

**✅ Action:** Update mobile app with Railway URL

---

## STEP 10: Rebuild APK

**Build the APK with the new Railway URL:**

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:**
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

**✅ Action:** Rebuild APK

**📝 APK ready:** [ ] Yes / [ ] No

---

## ✅ Deployment Complete!

**Your backend is now live on Railway!**

**Next steps:**
1. Install APK on device
2. Test all features
3. Share APK with users

---

## 🆘 Need Help?

**If you get stuck at any step:**

1. **Check Railway logs** - Go to Deployments → Latest → Logs
2. **Verify environment variables** - Service → Variables tab
3. **Test health endpoint** - `https://YOUR-URL.railway.app/health`
4. **Check this guide** - Go back to the step you're on

**Common Issues:**

- **Deployment fails:** Check logs, verify variables
- **Can't connect:** Verify URL, check CORS_ORIGINS
- **Migrations error:** Check Procfile has `release: alembic upgrade head || true`

---

## 📋 Quick Reference

**Railway Dashboard:** https://railway.app/dashboard

**Required Variables:**
- `JWT_SECRET` - Generate secure token
- `CORS_ORIGINS` - Set to `*`
- `ENVIRONMENT` - Set to `production`
- `DATABASE_URL` - Auto-set by PostgreSQL

**Your Railway URL:** _________________________

---

**Start with STEP 1: Open Railway Dashboard!** 🚀


