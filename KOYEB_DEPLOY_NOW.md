# 🚀 Deploy to Koyeb - Action Steps

## ⚡ Let's Deploy Now!

Follow these steps in order. Each step takes 1-2 minutes.

---

## ✅ STEP 1: Sign Up for Koyeb

**Do this now:**

1. **Open browser:** https://www.koyeb.com
2. **Click "Sign Up"** (top right)
3. **Sign up with GitHub** (easiest - one click)
   - Or use email/password
4. **Verify email** (if using email)

**✅ When done:** You're logged into Koyeb dashboard

**⏱️ Time:** ~1 minute

---

## ✅ STEP 2: Create New App

**Do this now:**

1. **In Koyeb dashboard, click "Create App"** button (big blue button)
2. **Select "GitHub"** as source
3. **Authorize Koyeb:**
   - Click "Authorize Koyeb"
   - You'll be redirected to GitHub
   - Login to GitHub if needed
   - Click "Install & Authorize" or "Authorize Koyeb"
   - Grant access to your repositories
4. **You'll be redirected back to Koyeb**

**✅ When done:** You see repository selection

**⏱️ Time:** ~1 minute

---

## ✅ STEP 3: Select Repository

**Do this now:**

1. **Find your repository:** `QuaresmaHarygens/Talkam`
2. **Click on it** to select
3. **Click "Next"** button

**✅ When done:** You see "Configure Your App" screen

**⏱️ Time:** ~10 seconds

---

## ✅ STEP 4: Configure App (⚠️ CRITICAL!)

**Set these EXACTLY:**

1. **Root Directory:**
   - **Find "Root Directory" field**
   - **It probably shows:** `/` or empty
   - **Change it to:** `backend` ⚠️ **VERY IMPORTANT!**
   - Type: `backend` in the field

2. **Build Command:**
   - Should show: `pip install -e .`
   - If not, change it to: `pip install -e .`

3. **Run Command:**
   - Should show: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - If not, change it to: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

4. **Region:**
   - Auto-selected (closest to you)
   - Can leave as is

5. **Click "Next"** button

**✅ When done:** You see "Add Services" screen

**⏱️ Time:** ~1 minute

**⚠️ DOUBLE-CHECK:** Root Directory MUST be `backend` (not `/` or empty)!

---

## ✅ STEP 5: Add PostgreSQL Database

**Do this now:**

1. **On "Add Services" screen, click "Add Service"** button
2. **Select "PostgreSQL"** from dropdown
3. **Configure:**
   - **Name:** `talkam-db` (or leave default)
   - **Region:** Same as app (recommended)
   - **Plan:** Free tier (512 MB)
4. **Click "Add PostgreSQL"** button

**✅ When done:** Database appears in services list

**⏱️ Time:** ~1 minute

**📝 Note:** `DATABASE_URL` will be auto-set ✅

---

## ✅ STEP 6: Set Up Redis (Upstash - Free)

**Open a NEW browser tab (keep Koyeb tab open):**

1. **Go to:** https://console.upstash.com
2. **Click "Sign Up"** (top right)
3. **Sign up with GitHub** (easiest - one click)
4. **After login, click "Create Database"** button
5. **Configure:**
   - **Name:** `talkam-redis`
   - **Type:** Select **"Regional"** (not Global)
   - **Primary Region:** Choose closest (e.g., `us-east-1`, `us-west-1`)
6. **Click "Create"** button
7. **Wait ~30 seconds** for database to be created
8. **Click on your database** (`talkam-redis`) to open it
9. **Copy the "Redis URL":**
   - Look for "Redis URL" or "Endpoint"
   - Format: `redis://default:password@host:port`
   - **Copy the entire URL** - you'll need it next!

**✅ When done:** Redis URL copied to clipboard

**⏱️ Time:** ~3 minutes

**📝 Keep both tabs open** - you'll need the URL in Koyeb!

---

## ✅ STEP 7: Set Environment Variables

**Back in Koyeb tab:**

1. **Click "Next"** (if still on services screen)
   - Or go to "Environment Variables" section
2. **You'll see environment variables section**
3. **Add each variable one by one:**

   **Variable 1: SECRET_KEY**
   - Click "Add Variable" or "+" button
   - **Key:** `SECRET_KEY`
   - **Value:** `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
   - Click "Add" or "Save"

   **Variable 2: REDIS_URL**
   - Click "Add Variable" or "+" button
   - **Key:** `REDIS_URL`
   - **Value:** (Paste Redis URL from Upstash - Step 6)
   - Click "Add" or "Save"

   **Variable 3: CORS_ORIGINS**
   - Click "Add Variable" or "+" button
   - **Key:** `CORS_ORIGINS`
   - **Value:** `*`
   - Click "Add" or "Save"

   **Variable 4: ENVIRONMENT**
   - Click "Add Variable" or "+" button
   - **Key:** `ENVIRONMENT`
   - **Value:** `production`
   - Click "Add" or "Save"

4. **Verify DATABASE_URL:**
   - Should already be there (auto-set by Koyeb)
   - If you see it, you're good! ✅
   - If not, go back and make sure you added PostgreSQL

5. **Click "Deploy"** or **"Next"** button

**✅ When done:** All variables are set

**⏱️ Time:** ~2 minutes

**📝 Your Variables Checklist:**
- ✅ `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- ✅ `REDIS_URL` = (from Upstash)
- ✅ `CORS_ORIGINS` = `*`
- ✅ `ENVIRONMENT` = `production`
- ✅ `DATABASE_URL` = (auto-set)

---

## ✅ STEP 8: Review and Deploy

**Final step:**

1. **Review the summary:**
   - App name: (auto-generated or you can change)
   - Region: (auto-selected)
   - Services: App + Database ✅
   - Environment variables: All set ✅

2. **Click "Deploy"** button (big blue button)

3. **Watch the deployment:**
   - You'll see "Building..." status
   - Then "Deploying..." status
   - Build takes ~5-10 minutes
   - Watch the logs if you want

4. **When complete:**
   - Status will show "Running" ✅
   - You'll see your app URL: `https://your-app-name.koyeb.app`
   - **Copy this URL!**

**✅ Deployment complete!**

**⏱️ Time:** ~10 minutes (mostly waiting)

---

## ✅ STEP 9: Test Your Deployment

**After deployment completes:**

**Test health endpoint:**
```bash
curl https://your-app-name.koyeb.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or test in browser:**
- Open: `https://your-app-name.koyeb.app/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://your-app-name.koyeb.app/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

## ✅ STEP 10: Update Mobile App

**After testing works:**

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app-name.koyeb.app
```

**Replace `your-app-name.koyeb.app` with your actual URL!**

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎉 You're Done!

**Your app is live at:**
`https://your-app-name.koyeb.app`

---

## 🔑 Quick Reference

**Your Secret Key:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Critical Settings:**
- Root Directory: `backend` ⚠️
- Build Command: `pip install -e .`
- Run Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

**Environment Variables:**
- `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- `REDIS_URL` = (from Upstash)
- `CORS_ORIGINS` = `*`
- `ENVIRONMENT` = `production`
- `DATABASE_URL` = (auto-set)

---

## 🆘 Troubleshooting

### Build Fails

**Check:**
- Root directory is `backend`
- Build command: `pip install -e .`
- Check logs in Koyeb dashboard

### App Won't Start

**Check logs:**
- Go to your app in Koyeb
- Click "Logs" tab
- Look for errors

**Common issues:**
- Missing environment variables
- Database connection issues
- Port configuration

### Database Connection Fails

**Verify:**
- `DATABASE_URL` is set (auto-set by Koyeb)
- Database is running
- Connection string format is correct

---

## 📊 Monitor Your App

**View Logs:**
- Go to your app in Koyeb
- Click "Logs" tab
- See real-time logs

**View Metrics:**
- Click "Metrics" tab
- See CPU, memory, requests

**View Deployments:**
- Click "Deployments" tab
- See deployment history

---

**Ready? Start with STEP 1: Sign up at https://www.koyeb.com** 🚀
