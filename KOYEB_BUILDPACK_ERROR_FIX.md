# 🔧 Fix: Buildpack Build Error (Exit Code 51)

## ❌ Error: "The 'build' step of buildpacks failed with exit code 51"

**Good news:** Backend directory is now found! ✅  
**Bad news:** Build is failing during the buildpack build step.

**Exit code 51** usually means:
- Missing dependencies
- Build command failing
- Python version issue
- Package installation error

---

## 🔍 Step 1: Check Build Logs

**Most important - we need to see the actual error:**

1. **In Koyeb dashboard, click on the failed deployment**
2. **Click "Logs" tab** or **expand "Logs" section**
3. **Scroll to the "Build" step logs**
4. **Look for error messages** like:
   - "No module named..."
   - "Could not find a version..."
   - "ERROR: Could not install packages..."
   - "pip install failed..."

**Share the error message from the logs!**

---

## 🔧 Step 2: Common Fixes

### Fix 1: Missing requirements.txt

**Problem:** Buildpack might not find dependencies

**Solution:**
- Ensure `requirements.txt` exists in `backend/` directory
- Or buildpack should detect `pyproject.toml`

**Check:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
ls -la requirements.txt
```

**If missing, it should be there (we saw it earlier).**

### Fix 2: Build Command Issue

**Problem:** Build command `pip install -e .` might be failing

**Solution:** Try alternative build commands:

**Option A: Use requirements.txt directly**
- Build Command: `pip install -r requirements.txt`

**Option B: Install in two steps**
- Build Command: `pip install --upgrade pip && pip install -e .`

**Option C: Explicit install**
- Build Command: `pip install --upgrade pip setuptools wheel && pip install -e .`

### Fix 3: Python Version

**Problem:** Wrong Python version detected

**Solution:**
- Add `runtime.txt` in `backend/` directory
- Content: `python-3.9` or `python-3.11`

### Fix 4: Missing System Dependencies

**Problem:** Some packages need system libraries

**Solution:**
- Buildpack should handle this, but might need adjustment

---

## ✅ Step 3: Update Build Configuration

**Try these build command options:**

### Option 1: Use requirements.txt (Simplest)

**In Koyeb Settings → Build:**
- **Build Command:** `pip install -r requirements.txt`
- **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Option 2: Upgrade pip first

**In Koyeb Settings → Build:**
- **Build Command:** `pip install --upgrade pip setuptools wheel && pip install -e .`
- **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### Option 3: Full install command

**In Koyeb Settings → Build:**
- **Build Command:** `pip install --upgrade pip && pip install --no-cache-dir -e . eval-type-backport`
- **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

---

## 🔍 Step 4: Check requirements.txt Location

**Verify requirements.txt is in backend/ directory:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
ls -la requirements.txt
cat requirements.txt | head -5
```

**It should exist and have content.**

---

## 🎯 Recommended Fix

**Try this first:**

1. **In Koyeb Settings → Build:**
   - **Build Command:** Change to `pip install -r requirements.txt`
   - **Keep Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

2. **Save and Redeploy**

**This is simpler and more reliable than `pip install -e .`**

---

## 📋 Action Items

1. **Check build logs** - Share the error message
2. **Try Build Command:** `pip install -r requirements.txt`
3. **Verify requirements.txt** exists in backend/
4. **Redeploy** and check logs again

---

## 🆘 If Still Failing

**After checking logs, common issues:**

### Issue: "No module named 'app'"
**Fix:** Work Directory must be `backend`

### Issue: "Could not find a version"
**Fix:** Update dependency versions in requirements.txt

### Issue: "ERROR: Could not install packages"
**Fix:** Try `pip install --upgrade pip` first

### Issue: "package directory 'app' does not exist"
**Fix:** Work Directory must be `backend`

---

## 🎯 Next Steps

1. **Check the build logs** in Koyeb
2. **Share the error message** from the logs
3. **Try changing Build Command** to `pip install -r requirements.txt`
4. **Redeploy**

**The build logs will tell us exactly what's wrong!** 🔍

---

**Check the build logs and share the error message!** 📋
