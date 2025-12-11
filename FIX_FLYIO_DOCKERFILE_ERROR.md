# Fix Fly.io Dockerfile Error 🔧

## ⚠️ Problem Identified

**Error:** `error: package directory 'app' does not exist`

**What's happening:**
- Dockerfile tries to run `pip install .` 
- But only `pyproject.toml` is copied first
- The `app/` directory is copied AFTER installation
- `pyproject.toml` specifies `packages = ["app"]`, so it needs `app/` to exist

## ✅ Solution

**Fixed the Dockerfile** - Now copies `app/` directory BEFORE installing.

**Changed:**
```dockerfile
# OLD (WRONG):
COPY pyproject.toml ./
RUN pip install .  # ❌ app/ doesn't exist yet!

# Copy application code
COPY app/ ./app/

# NEW (CORRECT):
COPY pyproject.toml ./
COPY app/ ./app/        # ✅ Copy app/ first
COPY alembic.ini ./
COPY alembic/ ./alembic/
RUN pip install .       # ✅ Now app/ exists!
```

## 📋 Next Steps

### Step 1: Verify Dockerfile is Fixed

**Check the updated Dockerfile:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
cat Dockerfile
```

**Should show:** `app/` copied before `pip install`

### Step 2: Add PostgreSQL (If Not Added)

**You said "no" to PostgreSQL during launch. Add it now:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly postgres create --name talkam-db --region lhr
fly postgres attach talkam-db
```

**This automatically sets `DATABASE_URL`**

### Step 3: Set Secrets

**Set environment variables:**
```bash
fly secrets set JWT_SECRET="8kes0ZPi4IbjVE7B_LXWma8Pj0m1Xk3Uc-5KuokGVnU"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

**Verify:**
```bash
fly secrets list
```

### Step 4: Update fly.toml (If Needed)

**Check `backend/fly.toml` - should have:**
```toml
[http_service]
  internal_port = 8000
```

**If port is different, update CMD in Dockerfile or fly.toml**

### Step 5: Deploy Again

**Now deploy with fixed Dockerfile:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly deploy
```

**This should work now!**

## ✅ What Was Fixed

**Dockerfile now:**
1. Copies `pyproject.toml`
2. Copies `app/` directory ✅
3. Copies `alembic.ini` and `alembic/`
4. THEN installs with `pip install .` ✅

**This ensures `app/` exists when pip tries to install the package**

## 🆘 If Still Fails

**Check:**
1. Dockerfile has correct order (app/ before pip install)
2. All files are in backend/ directory
3. `.dockerignore` isn't excluding app/

**Alternative: Use requirements.txt instead:**
```dockerfile
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY app/ ./app/
```

---

**Dockerfile is fixed! Try deploying again.** ✅

