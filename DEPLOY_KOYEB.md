# 🚀 Deploy to Koyeb - Serverless & Fast

## ⭐ Modern Serverless Platform

**Why Koyeb:**
- ✅ **Free tier** - Generous limits
- ✅ **Auto-deploys** from GitHub
- ✅ **Fast global network** - Edge computing
- ✅ **Easy setup** - 10 minutes
- ✅ **PostgreSQL included** - One click
- ✅ **HTTPS included** - Automatic
- ✅ **Auto-scaling** - Handles traffic

---

## 📋 Step-by-Step Setup

### Step 1: Sign Up for Koyeb

1. **Go to:** https://www.koyeb.com
2. **Click "Sign Up"** (top right)
3. **Sign up with GitHub** (easiest - one click)
   - Or use email/password
4. **Verify email** (if using email)

**⏱️ Time:** ~1 minute

**📝 Note:** Free tier includes:
- 2 services
- 512 MB RAM per service
- 10 GB bandwidth/month
- PostgreSQL database

---

### Step 2: Create New App

1. **After login, click "Create App"** button
2. **Select "GitHub"** as source
3. **Authorize Koyeb:**
   - Click "Authorize Koyeb"
   - Grant access to repositories
4. **Select Repository:**
   - Find: `QuaresmaHarygens/Talkam`
   - Click on it
5. **Click "Next"**

**⏱️ Time:** ~1 minute

---

### Step 3: Configure App

**Set these settings:**

1. **Root Directory:**
   - **Change to:** `backend` ⚠️ **IMPORTANT!**
   - Type: `backend` in the field

2. **Build Command:**
   - Should show: `pip install -e .`
   - If not, change it to: `pip install -e .`

3. **Run Command:**
   - Should show: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - If not, change it to: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

4. **Region:**
   - Auto-selected (closest to you)
   - Can change if needed

5. **Click "Next"**

**⏱️ Time:** ~1 minute

**⚠️ CRITICAL:** Root Directory MUST be `backend`!

---

### Step 4: Add PostgreSQL Database

1. **On "Add Services" screen, click "Add Service"**
2. **Select "PostgreSQL"**
3. **Configure:**
   - **Name:** `talkam-db` (or leave default)
   - **Region:** Same as app (recommended)
   - **Plan:** Free tier (512 MB)
4. **Click "Add PostgreSQL"**

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
   - Region: Choose closest
4. **Copy Redis URL:**
   - Format: `redis://default:password@host:port`
   - **Save this!**

**⏱️ Time:** ~2 minutes

---

### Step 6: Set Environment Variables

**Back in Koyeb tab:**

1. **Go to "Environment Variables" section**
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
   - Should already be there (auto-set)
   - If you see it, you're good! ✅

4. **Click "Deploy"** button

**⏱️ Time:** ~2 minutes

---

### Step 7: Deploy

1. **Click "Deploy"** button (big blue button)
2. **Koyeb will:**
   - Build your app
   - Install dependencies
   - Start the server
   - Show deployment progress

3. **Wait for deployment** (~5-10 minutes)
   - Watch the logs
   - Build should complete successfully

4. **When complete:**
   - Status shows "Running" ✅
   - You'll see your app URL: `https://your-app-name.koyeb.app`
   - **Copy this URL!**

**⏱️ Time:** ~10 minutes (mostly waiting)

---

### Step 8: Test Your Deployment

**Test health endpoint:**
```bash
curl https://your-app-name.koyeb.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or test in browser:**
- Open: `https://your-app-name.koyeb.app/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://your-app-name.koyeb.app/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

### Step 9: Update Mobile App

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app-name.koyeb.app
```

**Replace `your-app-name.koyeb.app` with your actual URL!**

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎉 You're Done!

**Your app is live at:**
`https://your-app-name.koyeb.app`

**Total time:** ~10 minutes

---

## 🔑 Quick Reference

**Your Secret Key:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Critical Settings:**
- Root Directory: `backend` ⚠️
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

### Build Fails

**Check:**
- Root directory is `backend`
- Build command: `pip install -e .`
- Check logs in Koyeb dashboard

### App Won't Start

**Check logs:**
- Go to your app in Koyeb
- Click "Logs" tab
- Look for errors

**Common issues:**
- Missing environment variables
- Database connection issues
- Port configuration

### Database Connection Fails

**Verify:**
- `DATABASE_URL` is set (auto-set by Koyeb)
- Database is running
- Connection string format is correct

---

## 📊 Koyeb Features

**Free Tier Includes:**
- ✅ 2 services
- ✅ 512 MB RAM per service
- ✅ 10 GB bandwidth/month
- ✅ PostgreSQL database
- ✅ Auto-scaling
- ✅ Global edge network
- ✅ HTTPS included
- ✅ Custom domains
- ✅ Environment variables
- ✅ Logs and metrics

**Limits:**
- 2 services max
- 512 MB RAM per service
- 10 GB bandwidth/month
- Sufficient for development/testing

**Upgrade Options:**
- Starter: $7/month (more resources)
- Professional: $29/month (even more)

---

## 🎯 Summary

✅ **Serverless platform**  
✅ **Free tier available**  
✅ **Auto-deploys from GitHub**  
✅ **Fast global network**  
✅ **PostgreSQL included**  
✅ **~10 minutes setup**  

**Perfect for modern FastAPI deployment!** 🚀

---

## 📋 Checklist

- [ ] Signed up for Koyeb
- [ ] Created app from GitHub
- [ ] Set root directory to `backend`
- [ ] Configured build and run commands
- [ ] Added PostgreSQL database
- [ ] Set up Redis (Upstash)
- [ ] Set environment variables:
  - [ ] `SECRET_KEY`
  - [ ] `REDIS_URL`
  - [ ] `CORS_ORIGINS`
  - [ ] `ENVIRONMENT`
  - [ ] `DATABASE_URL` (auto-set)
- [ ] Deployed successfully
- [ ] Tested health endpoint
- [ ] Updated mobile app
- [ ] Rebuilt APK

---

## 📝 Next Steps

1. ✅ **Deploy to Koyeb** (10 minutes)
2. ✅ **Set up Neon database** (if not using Koyeb PostgreSQL)
3. ✅ **Set up Upstash Redis** (2 minutes)
4. ✅ **Set environment variables** (2 minutes)
5. ✅ **Test deployment** (1 minute)
6. ✅ **Update mobile app** (5 minutes)

**Total: ~20 minutes for complete setup!**

---

**Ready to deploy? Start with Step 1: Sign up at https://www.koyeb.com** 🚀
