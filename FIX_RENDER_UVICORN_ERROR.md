# Fix Render "uvicorn: command not found" Error 🔧

## ⚠️ Problem

**Error:** `bash: line 1: uvicorn: command not found`
**Exit Status:** 127

**What this means:**
- Build succeeded, but `uvicorn` command is not found
- Dependencies might not be installed correctly
- Or `uvicorn` is not in PATH

## ✅ Solution

### Option 1: Use `python -m uvicorn` (Recommended)

**Change your Start Command in Render:**

1. **Go to Render Dashboard**
2. **Click on your service** (`talkam-xmx1`)
3. **Go to "Settings" tab**
4. **Find "Start Command"**
5. **Change from:**
   ```
   uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```
   
   **To:**
   ```
   python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```

6. **Click "Save Changes"**
7. **Render will auto-redeploy**

**Why this works:**
- `python -m uvicorn` uses Python's module system
- Works even if `uvicorn` isn't in PATH
- More reliable for deployment

### Option 2: Fix Build Command

**If Option 1 doesn't work, update Build Command:**

1. **Service → Settings → Build Command**
2. **Change to:**
   ```
   pip install -r requirements.txt
   ```
   
   **Or keep:**
   ```
   pip install -e .
   ```
   
   **But ensure `requirements.txt` exists** (I've created it for you)

3. **Save and redeploy**

### Option 3: Use requirements.txt

**I've created `backend/requirements.txt` for you.**

**In Render:**
1. **Service → Settings**
2. **Build Command:** `pip install -r requirements.txt`
3. **Start Command:** `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. **Save and redeploy**

## 📋 Quick Fix Steps

### Step 1: Update Start Command

1. **Render Dashboard** → Your Service → **Settings**
2. **Start Command:** Change to:
   ```
   python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```
3. **Save Changes**

### Step 2: Verify Build Command

**Should be one of:**
- `pip install -e .` (if using pyproject.toml)
- `pip install -r requirements.txt` (if using requirements.txt)

### Step 3: Redeploy

1. **Render auto-redeploys** when you save
2. **Or manually:** Service → "Manual Deploy" → "Deploy latest commit"
3. **Watch logs** to see if it works

## ✅ After Fix

**Test your service:**
```bash
curl https://talkam-xmx1.onrender.com/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

## 🆘 Still Not Working?

**Check:**
1. **Build logs** - Are dependencies installing?
2. **Python version** - Should be 3.9+
3. **Root Directory** - Should be `backend` (or empty if repo root is backend)
4. **Environment variables** - All set correctly?

**Common issues:**
- Wrong Python version
- Dependencies not installing
- Wrong root directory
- Missing environment variables

---

## 📝 Summary

**Quick Fix:**
1. Change Start Command to: `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`
2. Save and wait for redeploy
3. Test service

**This should fix the "uvicorn: command not found" error!** ✅

