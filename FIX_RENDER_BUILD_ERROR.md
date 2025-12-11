# Fix Render "No module named uvicorn" Error 🔧

## ⚠️ Problem

**Error:** `/opt/render/project/src/.venv/bin/python: No module named uvicorn`
**Exit Status:** 1

**What this means:**
- Dependencies are NOT being installed during build
- Build command might be wrong
- Or requirements.txt not being used

## ✅ Solution

### Fix Build Command in Render

**The build command needs to install dependencies properly.**

### Step 1: Update Build Command

1. **Go to Render Dashboard:** https://dashboard.render.com
2. **Click on your service** (`talkam-xmx1`)
3. **Go to "Settings" tab**
4. **Find "Build Command"**
5. **Change to:**
   ```
   pip install -r requirements.txt
   ```
   
   **OR if Root Directory is `backend`:**
   ```
   pip install -r requirements.txt
   ```
   
   **OR if Root Directory is empty (repo root):**
   ```
   cd backend && pip install -r requirements.txt
   ```

6. **Click "Save Changes"**

### Step 2: Verify Root Directory

**Check "Root Directory" setting:**

1. **Service → Settings → Root Directory**
2. **Should be:**
   - `backend` (if your repo root contains backend folder)
   - OR empty (if repo root IS the backend folder)

### Step 3: Verify requirements.txt Location

**requirements.txt should be in:**
- `backend/requirements.txt` (if Root Directory is `backend` or empty)
- OR root of repo (if Root Directory is empty and backend is at root)

**I've created it at:** `backend/requirements.txt`

### Step 4: Alternative - Use pyproject.toml

**If you prefer to use pyproject.toml:**

**Build Command:**
```
pip install -e .
```

**But make sure:**
- Root Directory is `backend` (where pyproject.toml is)
- OR pyproject.toml is at repo root

## 📋 Complete Settings Checklist

**In Render Dashboard → Your Service → Settings:**

1. **Root Directory:** `backend` (or empty if repo root is backend)
2. **Build Command:** `pip install -r requirements.txt`
3. **Start Command:** `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. **Environment:** Python 3

## 🔍 Debug Steps

### Check Build Logs

1. **Service → Events → Latest deployment → Logs**
2. **Look for:**
   - `Installing collected packages: uvicorn, fastapi, ...`
   - Should see uvicorn being installed

### If Still Not Working

**Try this Build Command:**
```
pip install --upgrade pip && pip install -r requirements.txt
```

**Or:**
```
python -m pip install --upgrade pip && python -m pip install -r requirements.txt
```

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

**Check these:**

1. **Root Directory:**
   - If repo structure is: `repo/backend/requirements.txt`
   - Then Root Directory should be: `backend`
   - Build Command: `pip install -r requirements.txt`

2. **If repo structure is:** `repo/requirements.txt` (at root)
   - Then Root Directory should be: empty
   - Build Command: `pip install -r requirements.txt`

3. **Verify requirements.txt exists:**
   - Check it's in the right location
   - Check it has uvicorn listed

4. **Check build logs:**
   - Should see "Installing uvicorn"
   - Should see "Successfully installed uvicorn"

---

## 📝 Quick Fix Summary

**Most likely fix:**

1. **Root Directory:** `backend`
2. **Build Command:** `pip install -r requirements.txt`
3. **Start Command:** `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. **Save and redeploy**

**This should fix the "No module named uvicorn" error!** ✅

