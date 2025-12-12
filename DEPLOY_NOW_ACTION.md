# 🚀 Deploy to DigitalOcean - Action Steps

## ✅ Ready to Deploy!

Follow these steps in order. Each step takes 1-2 minutes.

---

## 📋 STEP 1: Open DigitalOcean

**Do this now:**

1. **Open browser:** https://cloud.digitalocean.com
2. **Login** (you're already signed up ✅)
3. **You should see the dashboard**

**✅ When done:** You're on the DigitalOcean dashboard

**⏱️ Time:** ~30 seconds

---

## 📋 STEP 2: Create New App

**Do this now:**

1. **Click the big blue "Create" button** (top right corner)
2. **Select "App"** from the dropdown menu
3. **You'll see "Create App" screen**

**✅ When done:** You see "Create App" screen

**⏱️ Time:** ~10 seconds

---

## 📋 STEP 3: Connect GitHub

**Do this now:**

1. **Click "GitHub"** tab or button
2. **Click "Authorize DigitalOcean"** button
3. **You'll be redirected to GitHub:**
   - Login to GitHub if needed
   - Click "Install & Authorize" or "Authorize DigitalOcean"
   - Grant access to your repositories
4. **You'll be redirected back to DigitalOcean**

**✅ When done:** You're back in DigitalOcean, GitHub is connected

**⏱️ Time:** ~1 minute

---

## 📋 STEP 4: Select Repository

**Do this now:**

1. **Find your repository:** `QuaresmaHarygens/Talkam`
2. **Click on it** to select
3. **Click "Next"** button (bottom right)

**✅ When done:** You see "Configure Your App" screen

**⏱️ Time:** ~10 seconds

---

## 📋 STEP 5: Configure App (⚠️ CRITICAL!)

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

4. **Verify:**
   - Python version: Should show 3.9 or 3.10
   - Framework: Should detect FastAPI

5. **Click "Next"** button

**✅ When done:** You see "Add Resources" screen

**⏱️ Time:** ~1 minute

**⚠️ DOUBLE-CHECK:** Root Directory MUST be `backend` (not `/` or empty)!

---

## 📋 STEP 6: Add PostgreSQL Database

**Do this now:**

1. **Click "Add Resource"** button
2. **Select "Database"** from dropdown
3. **Choose Database Type:**
   - Select: **PostgreSQL**
4. **Choose Plan:**
   - **Dev Database** ($7/month) - Good for testing
   - **Basic Database** ($15/month) - For production
   - Choose one (you can change later)
5. **Database Name:** 
   - Leave default or type: `talkam-db`
6. **Click "Add Database"** button

**✅ When done:** Database appears in resources list

**⏱️ Time:** ~1 minute

**📝 Note:** `DATABASE_URL` will be auto-set ✅

---

## 📋 STEP 7: Set Up Redis (Upstash - Free)

**Open a NEW browser tab (keep DigitalOcean tab open):**

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

**📝 Keep both tabs open** - you'll need the URL in DigitalOcean!

---

## 📋 STEP 8: Set Environment Variables

**Back in DigitalOcean tab:**

1. **Click "Next"** (if still on resources screen)
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
   - **Value:** (Paste Redis URL from Upstash - Step 7)
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
   - Should already be there (auto-set by DigitalOcean)
   - If you see it, you're good! ✅
   - If not, go back and make sure you added PostgreSQL

5. **Click "Next"** or **"Save"** button

**✅ When done:** All variables are set

**⏱️ Time:** ~2 minutes

**📝 Your Variables Checklist:**
- ✅ `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- ✅ `REDIS_URL` = (from Upstash)
- ✅ `CORS_ORIGINS` = `*`
- ✅ `ENVIRONMENT` = `production`
- ✅ `DATABASE_URL` = (auto-set)

---

## 📋 STEP 9: Review and Deploy

**Final step:**

1. **Review the summary:**
   - App name: (auto-generated, you can change if you want)
   - Region: (auto-selected)
   - Resources: App + Database ✅
   - Environment variables: All set ✅

2. **Click "Create Resources"** or **"Deploy"** button (big blue button)

3. **Watch the deployment:**
   - You'll see "Building..." status
   - Then "Deploying..." status
   - Build takes ~5-10 minutes
   - Watch the logs if you want

4. **When complete:**
   - Status will show "Live" ✅
   - You'll see your app URL: `https://your-app-name-xxxxx.ondigitalocean.app`
   - **Copy this URL!**

**✅ Deployment complete!**

**⏱️ Time:** ~10 minutes (mostly waiting)

---

## 📋 STEP 10: Test Your Deployment

**After deployment completes:**

**Test health endpoint:**
```bash
curl https://your-app-name-xxxxx.ondigitalocean.app/health
```

**Or test in browser:**
- Open: `https://your-app-name-xxxxx.ondigitalocean.app/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://your-app-name-xxxxx.ondigitalocean.app/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

## 📋 STEP 11: Update Mobile App

**After testing works:**

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app-name-xxxxx.ondigitalocean.app
```

**Replace `your-app-name-xxxxx.ondigitalocean.app` with your actual URL!**

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
`https://your-app-name-xxxxx.ondigitalocean.app`

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

**Build fails:**
- Check root directory is `backend`
- Verify build command: `pip install -e .`
- Check logs in DigitalOcean dashboard

**App won't start:**
- Check all environment variables are set
- Verify `DATABASE_URL` is set
- Check runtime logs

**Database connection fails:**
- Verify PostgreSQL is running
- Check `DATABASE_URL` format
- Verify credentials

---

**Ready? Start with STEP 1: Open DigitalOcean!** 🚀
