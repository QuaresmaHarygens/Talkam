# 🚀 Koyeb One-Click Deploy - Quick Setup

## ⚡ Using the Deploy Button

You have a Koyeb deploy button! Let's use it and configure it properly.

---

## 📋 Step-by-Step: Using Deploy Button

### Step 1: Click the Deploy Button

**Click this link:**
```
https://app.koyeb.com/deploy?name=talkam&type=git&repository=QuaresmaHarygens%2FTalkam&branch=main&builder=dockerfile&instance_type=free&regions=fra&instances_min=0&autoscaling_sleep_idle_delay=300
```

**Or use the button:**
[![Deploy to Koyeb](https://www.koyeb.com/static/images/deploy/button.svg)](https://app.koyeb.com/deploy?name=talkam&type=git&repository=QuaresmaHarygens%2FTalkam&branch=main&builder=dockerfile&instance_type=free&regions=fra&instances_min=0&autoscaling_sleep_idle_delay=300)

**This will:**
- Open Koyeb deployment page
- Pre-fill repository: `QuaresmaHarygens/Talkam`
- Pre-fill branch: `main`
- Pre-fill region: `fra` (Frankfurt)

**⏱️ Time:** ~10 seconds

---

### Step 2: Sign Up / Login

1. **If not logged in, sign up:**
   - Click "Sign Up" or "Login"
   - Sign up with GitHub (easiest)
   - Authorize Koyeb

2. **You'll be redirected to deployment page**

**⏱️ Time:** ~1 minute

---

### Step 3: Configure Build Settings (⚠️ CRITICAL!)

**The deploy button uses Dockerfile builder, but we need to change this:**

1. **Find "Build" or "Builder" section**
2. **Change Builder:**
   - **From:** `Dockerfile` (if selected)
   - **To:** `Buildpack` or `Nixpacks` ⚠️ **IMPORTANT!**
   - Or keep Dockerfile if you want to use it

3. **Set Root Directory:**
   - **Find "Root Directory" or "Source Directory" field**
   - **Change to:** `backend` ⚠️ **CRITICAL!**
   - Type: `backend` in the field

4. **Set Build Command:**
   - **Find "Build Command" field**
   - **Set to:** `pip install -e .`
   - Or leave empty if using buildpack

5. **Set Run Command:**
   - **Find "Run Command" field**
   - **Set to:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

**⏱️ Time:** ~2 minutes

**⚠️ IMPORTANT:** 
- Root Directory MUST be `backend`
- If using Dockerfile, make sure it's in `backend/` directory
- If using Buildpack, it will auto-detect Python

---

### Step 4: Add PostgreSQL Database

1. **Scroll to "Services" or "Add Services" section**
2. **Click "Add Service"** or **"Add PostgreSQL"**
3. **Configure:**
   - **Name:** `talkam-db` (or leave default)
   - **Region:** Same as app (or leave default)
   - **Plan:** Free tier (512 MB)
4. **Click "Add"** or **"Create"**

**✅ When done:** Database appears in services list

**📝 Note:** `DATABASE_URL` will be auto-set ✅

**⏱️ Time:** ~1 minute

---

### Step 5: Set Up Redis (Upstash - Free)

**Open a NEW browser tab:**

1. **Go to:** https://console.upstash.com
2. **Sign up** (free, GitHub easiest)
3. **Create database:**
   - Name: `talkam-redis`
   - Type: Regional
   - Region: Choose closest to Frankfurt (e.g., `eu-west-1`)
4. **Copy Redis URL:**
   - Format: `redis://default:password@host:port`
   - **Save this!**

**⏱️ Time:** ~2 minutes

---

### Step 6: Set Environment Variables

**Back in Koyeb deployment page:**

1. **Find "Environment Variables" or "Secrets" section**
2. **Add each variable:**

   **Variable 1: SECRET_KEY**
   - Click "Add Variable" or "+"
   - **Key:** `SECRET_KEY`
   - **Value:** `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
   - Click "Add"

   **Variable 2: REDIS_URL**
   - Click "Add Variable" or "+"
   - **Key:** `REDIS_URL`
   - **Value:** (Paste Redis URL from Upstash)
   - Click "Add"

   **Variable 3: CORS_ORIGINS**
   - Click "Add Variable" or "+"
   - **Key:** `CORS_ORIGINS`
   - **Value:** `*`
   - Click "Add"

   **Variable 4: ENVIRONMENT**
   - Click "Add Variable" or "+"
   - **Key:** `ENVIRONMENT`
   - **Value:** `production`
   - Click "Add"

3. **Verify DATABASE_URL:**
   - Should be auto-set when you add PostgreSQL
   - If you see it, you're good! ✅

**⏱️ Time:** ~2 minutes

---

### Step 7: Review and Deploy

1. **Review all settings:**
   - Repository: `QuaresmaHarygens/Talkam` ✅
   - Branch: `main` ✅
   - Root Directory: `backend` ✅
   - Build Command: `pip install -e .` ✅
   - Run Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT` ✅
   - Region: `fra` (or your choice) ✅
   - Services: App + Database ✅
   - Environment variables: All set ✅

2. **Click "Deploy"** button (big blue button)

3. **Watch deployment:**
   - Status: "Building..."
   - Then: "Deploying..."
   - Takes ~5-10 minutes
   - Watch logs if you want

4. **When complete:**
   - Status: "Running" ✅
   - You'll see your app URL: `https://talkam-xxxxx.koyeb.app`
   - **Copy this URL!**

**⏱️ Time:** ~10 minutes (mostly waiting)

---

### Step 8: Test Your Deployment

**After deployment completes:**

**Test health endpoint:**
```bash
curl https://talkam-xxxxx.koyeb.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or test in browser:**
- Open: `https://talkam-xxxxx.koyeb.app/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://talkam-xxxxx.koyeb.app/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

### Step 9: Update Mobile App

**After testing works:**

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://talkam-xxxxx.koyeb.app
```

**Replace `talkam-xxxxx.koyeb.app` with your actual URL!**

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🔑 Quick Reference

**Your Secret Key:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Critical Settings:**
- Root Directory: `backend` ⚠️
- Builder: `Buildpack` or `Nixpacks` (not Dockerfile, unless you configure it)
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

### Build Fails with Dockerfile

**If using Dockerfile builder:**
- Make sure Dockerfile is in `backend/` directory
- Or change builder to `Buildpack` or `Nixpacks`

**Solution:**
- Change builder to `Buildpack` (recommended)
- Or ensure Dockerfile path is correct

### Root Directory Error

**If build can't find files:**
- Verify Root Directory is `backend`
- Check that `backend/` contains your app code

### App Won't Start

**Check logs:**
- Go to your app in Koyeb dashboard
- Click "Logs" tab
- Look for errors

**Common issues:**
- Missing environment variables
- Database connection issues
- Port configuration

---

## 📝 Note About Dockerfile

**The deploy button uses `builder=dockerfile`, but:**

- Your Dockerfile is in `backend/Dockerfile`
- Koyeb might look for it in root
- **Solution:** Change builder to `Buildpack` (easier) or adjust Dockerfile path

**If you want to use Dockerfile:**
- Make sure Root Directory is `backend`
- Koyeb should find `backend/Dockerfile`
- Or copy Dockerfile to root (not recommended)

**Recommended:** Use `Buildpack` builder - it's easier!

---

## 🎯 Summary

✅ **One-click deploy button ready**  
✅ **Just need to configure settings**  
✅ **Root Directory: `backend`** ⚠️  
✅ **Add PostgreSQL**  
✅ **Set environment variables**  
✅ **Deploy!**  

**Ready? Click the deploy button and follow the steps!** 🚀

---

**Deploy Button:**
[![Deploy to Koyeb](https://www.koyeb.com/static/images/deploy/button.svg)](https://app.koyeb.com/deploy?name=talkam&type=git&repository=QuaresmaHarygens%2FTalkam&branch=main&builder=dockerfile&instance_type=free&regions=fra&instances_min=0&autoscaling_sleep_idle_delay=300)
