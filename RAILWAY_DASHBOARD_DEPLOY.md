# Railway Dashboard Deployment - No CLI Needed! 🚀

## ✅ Use Railway Web Dashboard

**You can deploy completely via the web interface - no CLI needed!**

## 📋 Step-by-Step via Dashboard

### Step 1: Open Railway Dashboard

1. **Go to:** https://railway.app/dashboard
2. **Login** (if not already)
3. **Click your project** (ID: `d83eed38-27e4-4539-bd80-431d789d0c97`)

### Step 2: Add PostgreSQL Database

1. **In your project, click "New"**
2. **Select "Database"**
3. **Choose "Add PostgreSQL"**
4. **Railway automatically:**
   - Creates PostgreSQL database
   - Sets `DATABASE_URL` environment variable
   - Connects to your project

### Step 3: Add Backend Service

**Option A: From GitHub (Recommended)**

1. **Click "New"** → **"GitHub Repo"**
2. **Connect your GitHub account** (if not connected)
3. **Select your repository** (or create one)
4. **Railway auto-detects:**
   - Detects Python/FastAPI
   - Uses `railway.json` and `Procfile`
   - Auto-deploys

**Option B: Empty Service (Upload Files)**

1. **Click "New"** → **"Empty Service"**
2. **Click "Settings"** → **"Source"**
3. **Upload your backend folder** or connect via Git
4. **Railway builds and deploys**

### Step 4: Set Environment Variables

1. **Click on your backend service**
2. **Go to "Variables" tab**
3. **Add these variables:**

   **Required:**
   - `JWT_SECRET`: Generate with:
     ```bash
     python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
     ```
   - `CORS_ORIGINS`: `*`
   - `ENVIRONMENT`: `production`

   **Optional:**
   - `REDIS_URL`: (if you add Redis service)
   - `S3_ENDPOINT`: (for media storage)
   - `SMS_GATEWAY_URL`: (for SMS)

4. **Railway automatically sets:**
   - `DATABASE_URL` (from PostgreSQL service)
   - `PORT` (for the service)

### Step 5: Configure Service

1. **Click on your service**
2. **Go to "Settings" tab**
3. **Check:**
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Build Command:** (auto-detected from `pyproject.toml`)

### Step 6: Deploy

**Railway automatically deploys when:**
- You push to GitHub (if connected)
- You upload files
- You click "Redeploy"

**Watch deployment in "Deployments" tab**

### Step 7: Get Your URL

1. **Click on your service**
2. **Go to "Settings" tab**
3. **Scroll to "Domains" section**
4. **Click "Generate Domain"** (or use provided)
5. **Copy the URL** (e.g., `https://talkam-api.railway.app`)

### Step 8: Run Database Migrations

**Option A: Via Dashboard Terminal**

1. **Click on your service**
2. **Go to "Deployments" tab**
3. **Click on latest deployment**
4. **Open "Logs" or "Terminal"**
5. **Run:**
   ```bash
   alembic upgrade head
   ```

**Option B: Add to Procfile (Auto-runs)**

**The `Procfile` already has:**
```
release: alembic upgrade head || true
```

**This runs migrations automatically on deploy!**

### Step 9: Seed Test Data (Optional)

**Via Dashboard Terminal:**
```bash
python scripts/seed_data.py
```

### Step 10: Verify Deployment

**Test your deployed backend:**

1. **Get your Railway URL** from dashboard
2. **Test in browser or terminal:**
   ```bash
   curl https://your-app.railway.app/health
   ```
3. **Should return:** `{"status":"healthy","service":"talkam-api"}`

## 📱 After Deployment

### Update App Configuration

1. **Get Railway URL** from dashboard
2. **Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-RAILWAY-URL.railway.app/v1',  // Your Railway URL
));
```

3. **Rebuild APK:**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

4. **Share APK** - works for remote users!

## ✅ Checklist

- [ ] PostgreSQL database added
- [ ] Backend service created
- [ ] Environment variables set
- [ ] Service deployed
- [ ] URL generated
- [ ] Migrations run (or auto-run via Procfile)
- [ ] Health endpoint tested
- [ ] App updated with Railway URL
- [ ] APK rebuilt

## 🎯 Quick Reference

**Railway Dashboard:** https://railway.app/dashboard  
**Your Project ID:** `d83eed38-27e4-4539-bd80-431d789d0c97`

**Key Steps:**
1. Add PostgreSQL
2. Add Service (GitHub or upload)
3. Set Variables
4. Deploy
5. Get URL
6. Update app
7. Rebuild APK

---

**Use Railway dashboard - it's easier than CLI!** 🚀
