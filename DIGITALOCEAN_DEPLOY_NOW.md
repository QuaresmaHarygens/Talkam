# 🚀 DigitalOcean App Platform - Deploy Now!

## ⚡ Quick Setup Guide

Follow these steps to deploy Talkam to DigitalOcean App Platform.

---

## Step 1: Sign Up for DigitalOcean

1. **Go to:** https://cloud.digitalocean.com
2. **Click "Sign Up"**
3. **Create account** (email + password)
4. **Verify email** (check inbox)
5. **Get $5 free credit** automatically added ✅

**Time:** ~2 minutes

---

## Step 2: Create New App

1. **After login, click "Create"** (top right)
2. **Select "App"**
3. **Choose "GitHub"** as source
4. **Authorize DigitalOcean:**
   - Click "Authorize DigitalOcean"
   - Grant access to your repositories
   - Select: `QuaresmaHarygens/Talkam`
   - Click "Next"

**Time:** ~1 minute

---

## Step 3: Configure App

1. **Repository:** `QuaresmaHarygens/Talkam` (auto-selected)
2. **Branch:** `main` (default)
3. **Root Directory:** `backend` ⚠️ **IMPORTANT**
4. **Auto-detects:** Python 3.9 ✅

**Build Settings:**
- **Build Command:** `pip install -e .`
- **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

**Click "Next"**

**Time:** ~1 minute

---

## Step 4: Add PostgreSQL Database

1. **Click "Add Resource"** → **"Database"**
2. **Select:** PostgreSQL
3. **Choose Plan:**
   - **Dev Database** ($7/month) - Good for testing
   - **Basic Database** ($15/month) - For production
   - **OR** Use free Neon/Supabase (see Step 5 alternative)

4. **Database Name:** `talkam-db`
5. **Click "Add Database"**
6. **Auto-sets:** `DATABASE_URL` environment variable ✅

**Time:** ~1 minute

---

## Step 5: Set Up Redis (Upstash - Free)

**Option A: Use Upstash (Recommended - Free)**

1. **Open new tab:** https://console.upstash.com
2. **Sign up** (free, no credit card)
3. **Create Database:**
   - Click "Create Database"
   - Name: `talkam-redis`
   - Type: **Regional**
   - Region: Choose closest (e.g., `us-east-1`)
   - Click "Create"

4. **Copy Redis URL:**
   - Click on your database
   - Copy "Redis URL" (format: `redis://default:password@host:port`)
   - **Save this** - you'll need it in Step 6

**Time:** ~3 minutes

---

## Step 6: Set Environment Variables

**In DigitalOcean App settings:**

1. **Go to "Settings"** tab
2. **Click "Environment Variables"**
3. **Add these variables:**

   **SECRET_KEY:**
   ```
   SECRET_KEY=YOUR_GENERATED_SECRET_KEY
   ```
   (Use the key generated below)

   **REDIS_URL:**
   ```
   REDIS_URL=redis://default:password@host:port
   ```
   (From Upstash - Step 5)

   **CORS_ORIGINS:**
   ```
   CORS_ORIGINS=*
   ```

   **ENVIRONMENT:**
   ```
   ENVIRONMENT=production
   ```

   **DATABASE_URL:**
   - ✅ **Auto-set** by DigitalOcean (if you added PostgreSQL)
   - If using external database, add manually

4. **Click "Save"**

**Time:** ~2 minutes

---

## Step 7: Deploy

1. **Click "Save"** or **"Deploy"** button
2. **DigitalOcean will:**
   - Build your app
   - Install dependencies
   - Start the server
   - Show deployment progress

3. **Wait for deployment** (~5-10 minutes)
   - Watch the logs
   - Build should complete successfully

4. **Get your URL:**
   - Format: `https://your-app-name-xxxxx.ondigitalocean.app`
   - Shown in dashboard after deployment

**Time:** ~10 minutes

---

## Step 8: Test Deployment

**Test health endpoint:**
```bash
curl https://your-app-name-xxxxx.ondigitalocean.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**View API documentation:**
Open in browser: `https://your-app-name-xxxxx.ondigitalocean.app/docs`

**Test root endpoint:**
```bash
curl https://your-app-name-xxxxx.ondigitalocean.app/
```

---

## Step 9: Update Mobile App

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app-name-xxxxx.ondigitalocean.app
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://your-app-name-xxxxx.ondigitalocean.app/v1',
```

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## ✅ Deployment Checklist

- [ ] Signed up for DigitalOcean
- [ ] Created app from GitHub
- [ ] Set root directory to `backend`
- [ ] Configured build command: `pip install -e .`
- [ ] Configured run command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- [ ] Added PostgreSQL database
- [ ] Set up Upstash Redis
- [ ] Set environment variables:
  - [ ] `SECRET_KEY`
  - [ ] `REDIS_URL`
  - [ ] `CORS_ORIGINS=*`
  - [ ] `ENVIRONMENT=production`
- [ ] Deployed successfully
- [ ] Tested health endpoint
- [ ] Updated mobile app URL
- [ ] Rebuilt APK

---

## 🔑 Your Generated Secret Key

**SECRET_KEY:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Save this key** - you'll need it in Step 6!

---

## 🆘 Troubleshooting

### Build Fails

**Check:**
- Root directory is `backend` (not root)
- Build command: `pip install -e .`
- Run command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

### App Won't Start

**Check logs:**
- Go to "Runtime Logs" in dashboard
- Look for errors

**Common issues:**
- Missing environment variables
- Database connection issues
- Port configuration

### Database Connection Fails

**Verify:**
- `DATABASE_URL` is set (auto-set by DigitalOcean)
- Database is running
- Connection string format is correct

---

## 📊 Monitoring

**View Logs:**
- Go to "Runtime Logs" in dashboard
- Real-time logs available

**View Metrics:**
- Go to "Metrics" tab
- CPU, memory, requests

**View Deployments:**
- Go to "Deployments" tab
- See deployment history

---

## 💰 Cost

**Free Tier:**
- $5 credit monthly
- Enough for small apps

**Database:**
- Dev Database: $7/month
- Basic Database: $15/month
- **OR** Use free Neon/Supabase

**App:**
- Free tier available
- Scales with usage

---

## 🎯 Next Steps After Deployment

1. ✅ **Test all endpoints**
2. ✅ **Update mobile app**
3. ✅ **Rebuild APK**
4. ✅ **Test mobile app connection**
5. ✅ **Monitor logs and metrics**

---

## 📝 Summary

✅ **Easiest deployment option**  
✅ **No CLI needed**  
✅ **Auto-detects Python/FastAPI**  
✅ **PostgreSQL included**  
✅ **~15 minutes total setup**  

**Your app will be live at:** `https://your-app-name-xxxxx.ondigitalocean.app` 🚀

**Ready to start? Begin with Step 1!**
