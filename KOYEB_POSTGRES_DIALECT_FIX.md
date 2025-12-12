# 🔧 Fix: "Can't load plugin: sqlalchemy.dialects:postgres"

## ❌ Error: `sqlalchemy.exc.NoSuchModuleError: Can't load plugin: sqlalchemy.dialects:postgres`

**Problem:** SQLAlchemy can't find the PostgreSQL dialect because the DATABASE_URL format is wrong.

**The issue:** Koyeb provides DATABASE_URL as `postgres://...` but SQLAlchemy needs `postgresql://...` or `postgresql+asyncpg://...`

---

## 🔍 Root Cause

**Koyeb's DATABASE_URL format:**
- `postgres://user:pass@host:port/dbname` ❌ (old format)

**SQLAlchemy needs:**
- `postgresql://user:pass@host:port/dbname` ✅ (new format)
- Or: `postgresql+asyncpg://user:pass@host:port/dbname` ✅ (for async)

---

## ✅ Solution: Fix DATABASE_URL Format

**The code should already handle this, but let's verify and fix it.**

### Option 1: Update DATABASE_URL in Koyeb (Quick Fix)

**In Koyeb dashboard:**

1. **Go to Settings → Environment Variables**
2. **Find `DATABASE_URL`**
3. **Click edit**
4. **Change the URL:**
   - **From:** `postgres://...`
   - **To:** `postgresql://...` (just change `postgres` to `postgresql`)
   - **Or better:** `postgresql+asyncpg://...` (for async support)

5. **Save**
6. **Redeploy**

**Example:**
```
Before: postgres://koyeb-adm:pass@host:port/dbname
After:  postgresql+asyncpg://koyeb-adm:pass@host:port/dbname
```

---

### Option 2: Fix in Code (Better - Automatic)

**The code should already convert this, but let's verify it's working.**

**Check `backend/app/config.py` - it should convert `postgres://` to `postgresql+asyncpg://`**

**If not working, we need to ensure the conversion happens.**

---

## 🔧 Quick Fix Steps

### Step 1: Get Current DATABASE_URL

**In Koyeb:**
1. Go to Settings → Environment Variables
2. Find `DATABASE_URL`
3. Copy the value
4. Check if it starts with `postgres://` or `postgresql://`

### Step 2: Fix DATABASE_URL Format

**If it starts with `postgres://`:**

1. **Copy the DATABASE_URL value**
2. **Replace `postgres://` with `postgresql+asyncpg://`**
3. **Update in Koyeb:**
   - Edit `DATABASE_URL`
   - Paste the corrected URL
   - Save

**Example conversion:**
```
postgres://koyeb-adm:password@host:port/dbname
↓
postgresql+asyncpg://koyeb-adm:password@host:port/dbname
```

### Step 3: Redeploy

1. **Save the environment variable**
2. **Redeploy** in Koyeb
3. **Should work now!** ✅

---

## 🎯 Most Likely Fix

**The DATABASE_URL from Koyeb is in old format (`postgres://`).**

**Fix:**
1. Get DATABASE_URL from Koyeb
2. Change `postgres://` to `postgresql+asyncpg://`
3. Update in Koyeb
4. Redeploy

**This should fix the error!** ✅

---

## 📋 Action Steps

1. **Go to Koyeb Settings → Environment Variables**
2. **Find `DATABASE_URL`**
3. **Check the format** - does it start with `postgres://`?
4. **If yes, change to `postgresql+asyncpg://`**
5. **Save**
6. **Redeploy**

---

**Fix the DATABASE_URL format and redeploy!** 🔧
