# 🔧 Fix Koyeb Build Error

## ❌ Error: "An error occurred while building your application"

The deployment is failing during the build phase. Let's fix it!

---

## 🔍 Step 1: Check Build Logs

**First, let's see the actual error:**

1. **In Koyeb dashboard, click on the failed deployment** (`9b95a1b0`)
2. **Click "Build logs"** or **"Logs"** tab
3. **Look for error messages** - this will tell us what's wrong

**Common errors:**
- "No module named..."
- "package directory 'app' does not exist"
- "Could not find a version that satisfies..."
- "Root directory not found"

---

## 🔧 Step 2: Fix Configuration

**Most likely issues and fixes:**

### Issue 1: Root Directory Not Set

**Problem:** Koyeb is looking in the root directory, but your app is in `backend/`

**Fix:**
1. **Go to Settings** → **Source**
2. **Set "Root Directory" to:** `backend` ⚠️
3. **Save**

### Issue 2: Wrong Builder

**Problem:** Using Dockerfile builder but Dockerfile path is wrong

**Fix:**
1. **Go to Settings** → **Build**
2. **Change Builder to:** `Buildpack` or `Nixpacks` (recommended)
3. **Or** if using Dockerfile, make sure Root Directory is `backend`

### Issue 3: Missing Build Command

**Problem:** Buildpack can't auto-detect how to build

**Fix:**
1. **Go to Settings** → **Build**
2. **Set "Build Command" to:** `pip install -e .`
3. **Set "Run Command" to:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Issue 4: Missing requirements.txt

**Problem:** Buildpack needs `requirements.txt` in root directory

**Fix:**
- Buildpack will auto-detect from `pyproject.toml`
- Or ensure `requirements.txt` exists in `backend/` directory

---

## ✅ Step 3: Correct Configuration

**Here's the correct configuration:**

### Source Settings:
- **Repository:** `QuaresmaHarygens/Talkam`
- **Branch:** `main`
- **Root Directory:** `backend` ⚠️ **CRITICAL!**

### Build Settings:
- **Builder:** `Buildpack` or `Nixpacks` (recommended)
- **Build Command:** `pip install -e .`
- **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Environment Variables:
- `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- `REDIS_URL` = (from Upstash)
- `CORS_ORIGINS` = `*`
- `ENVIRONMENT` = `production`
- `DATABASE_URL` = (auto-set by Koyeb)

---

## 🔧 Step 4: Update Settings

**Do this now:**

1. **Go to your service in Koyeb dashboard**
2. **Click "Settings" tab**
3. **Find "Source" section:**
   - **Root Directory:** Change to `backend` ⚠️
   - **Save**

4. **Find "Build" section:**
   - **Builder:** Change to `Buildpack` or `Nixpacks`
   - **Build Command:** `pip install -e .`
   - **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Save**

5. **Click "Redeploy"** button

---

## 🔍 Step 5: Check Build Logs Again

**After redeploying:**

1. **Watch the build logs** in real-time
2. **Look for errors:**
   - If you see "No module named...", dependencies are missing
   - If you see "package directory 'app' does not exist", root directory is wrong
   - If you see "Could not find...", dependency version issue

**Share the error message** and I'll help fix it!

---

## 🆘 Common Fixes

### Fix 1: Root Directory Issue

**Error:** "package directory 'app' does not exist"

**Solution:**
- Set Root Directory to `backend` in Settings → Source

### Fix 2: Missing Dependencies

**Error:** "No module named 'fastapi'" or similar

**Solution:**
- Ensure `requirements.txt` exists in `backend/`
- Or buildpack will use `pyproject.toml`
- Check build command: `pip install -e .`

### Fix 3: Python Version

**Error:** "Python version not found"

**Solution:**
- Buildpack auto-detects Python version
- Or specify in `runtime.txt` in `backend/` directory

### Fix 4: Build Command Issue

**Error:** "Command failed" during build

**Solution:**
- Set Build Command: `pip install -e .`
- Make sure you're in `backend/` directory (via Root Directory setting)

---

## 📋 Quick Fix Checklist

- [ ] Root Directory set to `backend` in Settings → Source
- [ ] Builder set to `Buildpack` or `Nixpacks` in Settings → Build
- [ ] Build Command: `pip install -e .`
- [ ] Run Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- [ ] All environment variables set
- [ ] PostgreSQL database added
- [ ] Redeploy after changes

---

## 🎯 Most Likely Fix

**The most common issue is Root Directory not set to `backend`.**

**Quick fix:**
1. Go to Settings → Source
2. Set Root Directory: `backend`
3. Save
4. Click "Redeploy"

**This should fix 90% of build errors!**

---

## 📝 Next Steps

1. **Check build logs** to see exact error
2. **Update Root Directory** to `backend`
3. **Change Builder** to `Buildpack`
4. **Redeploy**
5. **Check logs again** if still failing

**Share the build log error message and I'll help fix it!** 🔧
