# Render Build Fix - Step by Step 🛠️

## 🎯 Quick Fix

**The issue:** Dependencies aren't being installed during build.

## 📋 Exact Steps to Fix

### Step 1: Go to Render Settings

1. **Open:** https://dashboard.render.com
2. **Click:** Your service (`talkam-xmx1`)
3. **Click:** "Settings" tab

### Step 2: Check Root Directory

**Find "Root Directory" field:**

- **If your repo structure is:**
  ```
  repo/
    backend/
      requirements.txt
      app/
  ```
  **Then set Root Directory to:** `backend`

- **If your repo structure is:**
  ```
  repo/
    requirements.txt
    app/
  ```
  **Then set Root Directory to:** (empty/blank)

### Step 3: Update Build Command

**Find "Build Command" field:**

**Change to:**
```
pip install -r requirements.txt
```

**OR if Root Directory is empty and backend is a subfolder:**
```
cd backend && pip install -r requirements.txt
```

### Step 4: Verify Start Command

**Find "Start Command" field:**

**Should be:**
```
python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### Step 5: Save and Deploy

1. **Click "Save Changes"**
2. **Render will auto-redeploy**
3. **Go to "Events" tab**
4. **Watch the build logs**

### Step 6: Check Build Logs

**In build logs, you should see:**
```
Collecting uvicorn[standard]>=0.30.0
  Downloading uvicorn-...
Installing collected packages: uvicorn, fastapi, ...
Successfully installed uvicorn-0.30.0 ...
```

**If you see this, dependencies are installing correctly!**

## ✅ Complete Settings

**Your Render settings should be:**

- **Root Directory:** `backend` (or empty based on your structure)
- **Build Command:** `pip install -r requirements.txt`
- **Start Command:** `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- **Environment:** Python 3

## 🧪 Test After Fix

**Once deployment succeeds:**

```bash
curl https://talkam-xmx1.onrender.com/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

---

**Follow these exact steps and your deployment should work!** ✅

