# Check or Create Backend Service in Railway 🔍

## 🎯 How to Check if You Have a Backend Service

### Step 1: Look at Your Railway Dashboard

**In Railway Dashboard (https://railway.app/dashboard):**

1. **Look at the left sidebar** - You should see a list of services
2. **Check what services you have:**
   - ✅ **Postgres** - Database (you already have this)
   - ❓ **Backend Service** - Your FastAPI app (check if this exists)

### Step 2: Identify Your Services

**Services you might see:**
- `Postgres` or `PostgreSQL` - Database (you have this)
- `talkam-backend` or `backend` or `api` - Backend service (check if exists)
- Any other service names

**If you see:**
- ✅ **Only Postgres** → You need to create backend service
- ✅ **Postgres + Another Service** → That other service is likely your backend!

## 🆕 How to Create Backend Service (If Needed)

**If you only see Postgres, create the backend service:**

### Option A: From GitHub Repo (Recommended - Easiest)

**Prerequisites:**
- Your code in a GitHub repository

**Steps:**
1. **In Railway dashboard, click the "+" button** (top right or in project view)
2. **Select "GitHub Repo"**
3. **Connect GitHub account** (if not connected)
4. **Select your repository** that contains the `backend/` folder
5. **Railway will:**
   - Auto-detect Python/FastAPI
   - Use your `railway.json` and `Procfile`
   - Start deploying automatically

**After deployment:**
- Go to the new service → Settings → Domains
- Generate domain to get your URL

### Option B: Empty Service (No GitHub)

**Steps:**
1. **Click "+" → "Empty Service"**
2. **Name it:** `talkam-backend` (or any name)
3. **Configure it:**
   - Go to Settings → Source
   - Connect GitHub repo OR
   - Use Railway CLI to deploy

**After creating:**
- Set environment variables
- Deploy
- Get URL from Settings → Domains

## 📋 Quick Checklist

**Check in Railway Dashboard:**

- [ ] Do you see Postgres? (Yes - you have this)
- [ ] Do you see another service besides Postgres?
  - [ ] Yes → That's your backend! Click it and get URL
  - [ ] No → You need to create backend service

## 🎯 What Your Backend Service Should Look Like

**When you have a backend service, it should:**
- Be a separate service from Postgres
- Show "Deployments" tab with build logs
- Have "Variables" tab for environment variables
- Have "Settings" tab with "Domains" section
- Be running/deployed (not just created)

## 🔍 How to Identify Backend Service

**Your backend service will:**
- Have Python/FastAPI icon or name
- Show deployment logs when you click on it
- Have environment variables like `JWT_SECRET`, `CORS_ORIGINS`
- Have a URL in Settings → Domains (after generating)

**Postgres service will:**
- Have PostgreSQL elephant icon
- Show "Database" tab
- Have database connection URL (not API URL)

## ✅ Action Plan

**Right Now:**

1. **Open Railway Dashboard:** https://railway.app/dashboard
2. **Look at left sidebar** - Count your services
3. **If you see:**
   - **Only Postgres** → Follow "Create Backend Service" steps above
   - **Postgres + Another Service** → Click the other service and get its URL

## 🚀 After Creating Backend Service

**Once you create/deploy backend service:**

1. **Set Environment Variables:**
   - `JWT_SECRET` - Generate with: `python3 -c 'import secrets; print(secrets.token_urlsafe(32))'`
   - `CORS_ORIGINS` - Set to `*`
   - `ENVIRONMENT` - Set to `production`
   - `DATABASE_URL` - Auto-set by Railway (from Postgres)

2. **Deploy:**
   - Railway auto-deploys from GitHub
   - Or manually deploy

3. **Get URL:**
   - Service → Settings → Domains
   - Generate domain
   - Copy URL

4. **Update Mobile App:**
   ```bash
   ./scripts/update_railway_url.sh https://YOUR-URL.railway.app
   ```

## 🆘 Still Not Sure?

**Check your Railway project:**

1. **How many services do you see?**
   - 1 service = Only Postgres (need to create backend)
   - 2+ services = One is likely your backend

2. **What are the service names?**
   - Postgres = Database
   - Anything else = Likely your backend

3. **Click on each service:**
   - If it has "Deployments" with build logs → Backend service
   - If it has "Database" tab → Postgres database

---

**Check your Railway dashboard now and see how many services you have!** 🔍

