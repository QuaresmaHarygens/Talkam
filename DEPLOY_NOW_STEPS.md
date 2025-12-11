# 🚀 Deploy Now - Remaining Steps

## ✅ Step 1: COMPLETE - Signed Up!

Now let's deploy your app. Follow these steps:

---

## 📋 Step 2: Create New App

**Do this now:**

1. **In DigitalOcean dashboard, click the big blue "Create" button** (top right)
2. **Select "App"** from the dropdown menu
3. **Choose "GitHub"** as your source
4. **Authorize DigitalOcean:**
   - Click "Authorize DigitalOcean" button
   - You'll be redirected to GitHub
   - Login to GitHub if needed
   - Click "Install & Authorize" or "Authorize DigitalOcean"
   - Grant access to your repositories
5. **Select your repository:**
   - Find: `QuaresmaHarygens/Talkam`
   - Click on it to select
6. **Click "Next"** button (bottom right)

**✅ You should see:** "Configure Your App" screen

**⏱️ Time:** ~1 minute

---

## 📋 Step 3: Configure App (CRITICAL!)

**⚠️ IMPORTANT - Set these exactly:**

1. **Root Directory:**
   - **Find the "Root Directory" field**
   - **Change it from:** `/` or empty
   - **Change it to:** `backend` ⚠️ **CRITICAL!**
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

**✅ You should see:** "Add Resources" screen

**⏱️ Time:** ~1 minute

**⚠️ Double-check:** Root Directory MUST be `backend` (not `/` or empty!)

---

## 📋 Step 4: Add PostgreSQL Database

**Do this now:**

1. **On "Add Resources" screen, click "Add Resource"** button
2. **Select "Database"** from the dropdown
3. **Choose Database Type:**
   - Select: **PostgreSQL** (should be default)
4. **Choose Plan:**
   - **Dev Database** ($7/month) - Good for testing
   - **Basic Database** ($15/month) - For production
   - Choose one (you can change later)
5. **Database Name:** 
   - Leave default or type: `talkam-db`
6. **Click "Add Database"** button

**✅ You should see:** Database appears in the resources list

**⏱️ Time:** ~1 minute

**📝 Note:** DigitalOcean will automatically set `DATABASE_URL` environment variable ✅

---

## 📋 Step 5: Set Up Redis (Upstash - Free)

**Do this in a NEW browser tab:**

1. **Open new tab:** https://console.upstash.com
2. **Click "Sign Up"** (top right)
3. **Sign up with:**
   - GitHub (easiest - one click)
   - Or email/password
4. **After login, click "Create Database"** button
5. **Configure database:**
   - **Name:** `talkam-redis`
   - **Type:** Select **"Regional"** (not Global)
   - **Primary Region:** Choose closest region (e.g., `us-east-1`, `us-west-1`, `eu-west-1`)
6. **Click "Create"** button
7. **Wait ~30 seconds** for database to be created
8. **Click on your database** (`talkam-redis`) to open it
9. **Copy the "Redis URL":**
   - Look for "Redis URL" or "Endpoint"
   - Format: `redis://default:password@host:port`
   - **Copy the entire URL** - you'll need it next!

**✅ You should have:** Redis URL copied to clipboard

**⏱️ Time:** ~3 minutes

**📝 Keep this tab open** - you'll need the URL in Step 6

---

## 📋 Step 6: Set Environment Variables

**Back in DigitalOcean tab:**

1. **In DigitalOcean, click "Next"** (if still on resources screen)
   - Or go to "Environment Variables" section
2. **You'll see environment variables section**
3. **Add each variable one by one:**

   **Variable 1: SECRET_KEY**
   - Click "Add Variable" or "Edit"
   - **Key:** `SECRET_KEY`
   - **Value:** `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
   - Click "Add" or "Save"

   **Variable 2: REDIS_URL**
   - Click "Add Variable"
   - **Key:** `REDIS_URL`
   - **Value:** (Paste the Redis URL from Upstash - Step 5)
   - Click "Add" or "Save"

   **Variable 3: CORS_ORIGINS**
   - Click "Add Variable"
   - **Key:** `CORS_ORIGINS`
   - **Value:** `*`
   - Click "Add" or "Save"

   **Variable 4: ENVIRONMENT**
   - Click "Add Variable"
   - **Key:** `ENVIRONMENT`
   - **Value:** `production`
   - Click "Add" or "Save"

4. **Verify DATABASE_URL:**
   - Should already be there (auto-set by DigitalOcean)
   - If you see it, you're good! ✅
   - If not, go back and make sure you added PostgreSQL

5. **Click "Next"** or **"Save"** button

**✅ You should see:** All variables listed

**⏱️ Time:** ~2 minutes

**📝 Your Variables Checklist:**
- ✅ `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- ✅ `REDIS_URL` = (from Upstash)
- ✅ `CORS_ORIGINS` = `*`
- ✅ `ENVIRONMENT` = `production`
- ✅ `DATABASE_URL` = (auto-set)

---

## 📋 Step 7: Review and Deploy

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

## 📋 Step 8: Test Your Deployment

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

## 📋 Step 9: Update Mobile App

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

**✅ APK ready with new backend URL!**

---

## 🎉 You're Done!

**Your app is live at:**
`https://your-app-name-xxxxx.ondigitalocean.app`

**Next:**
1. Test all endpoints
2. Update mobile app
3. Rebuild APK
4. Test mobile app connection

---

## 🆘 Need Help?

**If build fails:**
- Check root directory is `backend`
- Verify build command: `pip install -e .`
- Check logs in DigitalOcean dashboard

**If app won't start:**
- Check all environment variables are set
- Verify `DATABASE_URL` is set
- Check runtime logs

**If database connection fails:**
- Verify PostgreSQL is running
- Check `DATABASE_URL` format
- Verify credentials

---

**Ready? Start with Step 2: Create New App!** 🚀
