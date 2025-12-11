# 🚀 DigitalOcean Quick Start - Step by Step

## ⚡ Let's Deploy Talkam Now!

Follow these steps in order. I'll guide you through each one.

---

## ✅ Step 1: Sign Up for DigitalOcean

**Action Required:**

1. **Open in browser:** https://cloud.digitalocean.com
2. **Click "Sign Up"** (top right)
3. **Enter:**
   - Email address
   - Password
   - Confirm password
4. **Click "Create Account"**
5. **Verify email** (check inbox, click verification link)
6. **Complete profile** (optional, can skip)

**✅ When done:** You'll see the DigitalOcean dashboard

**⏱️ Time:** ~2 minutes

**📝 Note:** You'll automatically get $5 free credit monthly

---

## ✅ Step 2: Create New App

**Action Required:**

1. **In DigitalOcean dashboard, click "Create"** (top right, blue button)
2. **Select "App"** from dropdown
3. **Choose "GitHub"** as source
4. **Authorize DigitalOcean:**
   - Click "Authorize DigitalOcean"
   - You may need to login to GitHub
   - Grant access to repositories
   - Click "Install & Authorize"
5. **Select Repository:**
   - Find: `QuaresmaHarygens/Talkam`
   - Click on it
6. **Click "Next"**

**✅ When done:** You'll see the "Configure Your App" screen

**⏱️ Time:** ~1 minute

---

## ✅ Step 3: Configure App Settings

**⚠️ CRITICAL - Set these exactly:**

1. **Root Directory:**
   - **Change from:** `/` (root)
   - **Change to:** `backend` ⚠️ **IMPORTANT**
   - Type: `backend` in the field

2. **Build Command:**
   - Should auto-detect, but verify:
   - **Should be:** `pip install -e .`
   - If not, change it to: `pip install -e .`

3. **Run Command:**
   - **Should be:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - If not, change it to: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

4. **Auto-detects:**
   - ✅ Python 3.9 (should show automatically)
   - ✅ FastAPI (should detect)

5. **Click "Next"** (bottom right)

**✅ When done:** You'll see "Add Resources" screen

**⏱️ Time:** ~1 minute

**⚠️ Double-check:** Root Directory is `backend` (not `/` or empty)

---

## ✅ Step 4: Add PostgreSQL Database

**Action Required:**

1. **On "Add Resources" screen, click "Add Resource"** button
2. **Select "Database"** from dropdown
3. **Choose Database Type:**
   - Select: **PostgreSQL**
4. **Choose Plan:**
   - **Option A:** Dev Database ($7/month) - Good for testing
   - **Option B:** Basic Database ($15/month) - For production
   - **Option C:** Use free external database (Neon/Supabase) - Skip this step
5. **Database Name:** `talkam-db` (or leave default)
6. **Click "Add Database"**

**✅ When done:** Database appears in resources list, `DATABASE_URL` auto-set ✅

**⏱️ Time:** ~1 minute

**📝 Note:** DigitalOcean automatically sets `DATABASE_URL` environment variable

---

## ✅ Step 5: Set Up Redis (Upstash - Free)

**Action Required (in new tab):**

1. **Open new browser tab:** https://console.upstash.com
2. **Click "Sign Up"** (top right)
3. **Sign up options:**
   - Use GitHub (easiest)
   - Or email/password
4. **After login, click "Create Database"**
5. **Configure:**
   - **Name:** `talkam-redis`
   - **Type:** **Regional** (not Global)
   - **Region:** Choose closest to DigitalOcean (e.g., `us-east-1`, `us-west-1`)
   - **Primary Region:** Select from dropdown
6. **Click "Create"**
7. **Wait for database to be created** (~30 seconds)
8. **Click on your database** (`talkam-redis`)
9. **Copy the "Redis URL":**
   - Format: `redis://default:password@host:port`
   - **Save this URL** - you'll need it in Step 6!

**✅ When done:** You have Redis URL copied

**⏱️ Time:** ~3 minutes

**📝 Note:** Upstash is free, no credit card needed

---

## ✅ Step 6: Set Environment Variables

**Action Required (back in DigitalOcean tab):**

1. **In DigitalOcean, click "Next"** (if still on resources screen)
2. **You'll see "Environment Variables" section**
3. **Click "Edit"** or **"Add Variable"** for each:

   **Add Variable 1: SECRET_KEY**
   - **Key:** `SECRET_KEY`
   - **Value:** `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
   - Click "Add" or "Save"

   **Add Variable 2: REDIS_URL**
   - **Key:** `REDIS_URL`
   - **Value:** (Paste the Redis URL from Upstash - Step 5)
   - Click "Add" or "Save"

   **Add Variable 3: CORS_ORIGINS**
   - **Key:** `CORS_ORIGINS`
   - **Value:** `*`
   - Click "Add" or "Save"

   **Add Variable 4: ENVIRONMENT**
   - **Key:** `ENVIRONMENT`
   - **Value:** `production`
   - Click "Add" or "Save"

4. **Verify DATABASE_URL:**
   - Should already be there (auto-set by DigitalOcean)
   - If not, go back and add PostgreSQL database

5. **Click "Next"** or **"Save"**

**✅ When done:** All variables are set

**⏱️ Time:** ~2 minutes

**📝 Your Variables:**
- ✅ `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- ✅ `REDIS_URL` = (from Upstash)
- ✅ `CORS_ORIGINS` = `*`
- ✅ `ENVIRONMENT` = `production`
- ✅ `DATABASE_URL` = (auto-set)

---

## ✅ Step 7: Review and Deploy

**Action Required:**

1. **Review Summary:**
   - App name: (auto-generated or you can change)
   - Region: (auto-selected)
   - Resources: App + Database
   - Environment variables: All set ✅

2. **Click "Create Resources"** or **"Deploy"** button

3. **Wait for deployment:**
   - Build starts automatically
   - Watch the logs
   - Build takes ~5-10 minutes
   - You'll see progress: "Building..." → "Deploying..." → "Live"

4. **When complete:**
   - Status shows "Live" ✅
   - You'll see your app URL: `https://your-app-name-xxxxx.ondigitalocean.app`
   - **Copy this URL!**

**✅ When done:** App is deployed and live!

**⏱️ Time:** ~10 minutes (mostly waiting)

**📝 Note:** First deployment takes longer, subsequent ones are faster

---

## ✅ Step 8: Test Deployment

**Action Required:**

**Test health endpoint:**
```bash
curl https://your-app-name-xxxxx.ondigitalocean.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or test in browser:**
- Open: `https://your-app-name-xxxxx.ondigitalocean.app/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API documentation:**
- Open: `https://your-app-name-xxxxx.ondigitalocean.app/docs`
- Should see FastAPI Swagger UI

**✅ When done:** App is working!

**⏱️ Time:** ~1 minute

---

## ✅ Step 9: Update Mobile App

**Action Required:**

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app-name-xxxxx.ondigitalocean.app
```

**Replace `your-app-name-xxxxx.ondigitalocean.app` with your actual URL!**

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://your-app-name-xxxxx.ondigitalocean.app/v1',
```

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

**✅ When done:** APK is ready with new backend URL

**⏱️ Time:** ~5 minutes

---

## 🎉 Deployment Complete!

**Your app is live at:**
`https://your-app-name-xxxxx.ondigitalocean.app`

**Next steps:**
1. ✅ Test all endpoints
2. ✅ Update mobile app
3. ✅ Rebuild APK
4. ✅ Test mobile app connection

---

## 🆘 Troubleshooting

### Build Fails
- Check root directory is `backend`
- Verify build command: `pip install -e .`
- Check logs in "Runtime Logs"

### App Won't Start
- Check all environment variables are set
- Verify `DATABASE_URL` is set
- Check "Runtime Logs" for errors

### Can't Connect to Database
- Verify PostgreSQL database is running
- Check `DATABASE_URL` format
- Verify database credentials

---

## 📊 Monitor Your App

**View Logs:**
- Go to your app in DigitalOcean
- Click "Runtime Logs" tab
- See real-time logs

**View Metrics:**
- Click "Metrics" tab
- See CPU, memory, requests

**View Deployments:**
- Click "Deployments" tab
- See deployment history

---

**Ready to start? Begin with Step 1!** 🚀
