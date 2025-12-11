# Quick Deploy to DigitalOcean App Platform 🚀

## ⭐ Easiest Deployment Option - No CLI Needed!

**Why DigitalOcean:**
- ✅ Web interface (no CLI)
- ✅ Auto-detects Python/FastAPI
- ✅ Free $5 credit monthly
- ✅ PostgreSQL included
- ✅ ~10 minutes setup

---

## Step 1: Sign Up

1. **Go to:** https://cloud.digitalocean.com
2. **Sign up** (get $5 free credit)
3. **Verify email**

---

## Step 2: Create App

1. **Click "Create"** → **"App"**
2. **Connect GitHub:**
   - Click "GitHub"
   - Authorize DigitalOcean
   - Select your repository: `QuaresmaHarygens/Talkam`
   - Select branch: `main`

3. **Configure:**
   - **Root Directory:** `backend`
   - **Build Command:** `pip install -e .`
   - **Run Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Auto-detects:** Python 3.9 ✅

---

## Step 3: Add PostgreSQL Database

1. **Click "Add Resource"** → **"Database"**
2. **Select:** PostgreSQL
3. **Choose Plan:** Basic ($15/month) or Dev ($7/month)
   - Or use free Neon/Supabase and set `DATABASE_URL` manually
4. **Database name:** `talkam-db`
5. **Click "Add Database"**
   - **Auto-sets** `DATABASE_URL` environment variable ✅

---

## Step 4: Set Environment Variables

1. **Go to "Settings"** → **"Environment Variables"**
2. **Add these variables:**

   **Generate SECRET_KEY:**
   ```bash
   python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
   ```

   **Add variables:**
   - `SECRET_KEY` - Generated key
   - `REDIS_URL` - Get from Upstash (see below)
   - `CORS_ORIGINS` - `*`
   - `ENVIRONMENT` - `production`
   - `DATABASE_URL` - Auto-set by DigitalOcean ✅

---

## Step 5: Set Up Redis (Upstash - Free)

1. **Sign up:** https://console.upstash.com
2. **Create Database:**
   - Click "Create Database"
   - Name: `talkam-redis`
   - Type: Regional
   - Region: Choose closest to DigitalOcean
   - Click "Create"

3. **Copy Redis URL:**
   - Click on your database
   - Copy "Redis URL" (format: `redis://default:password@host:port`)
   - Add to DigitalOcean environment variables as `REDIS_URL`

---

## Step 6: Deploy

1. **Click "Save"** or **"Deploy"**
2. **DigitalOcean auto-deploys:**
   - Builds your app
   - Installs dependencies
   - Starts the server
   - Shows deployment logs

3. **Wait for deployment** (~5 minutes)

4. **Get your URL:**
   - Format: `https://your-app-name-xxxxx.ondigitalocean.app`
   - Shown in dashboard

---

## Step 7: Test Deployment

**Test health endpoint:**
```bash
curl https://your-app-name-xxxxx.ondigitalocean.app/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**View API docs:**
Open in browser: `https://your-app-name-xxxxx.ondigitalocean.app/docs`

---

## Step 8: Update Mobile App

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

## ✅ Complete Setup Checklist

- [ ] Signed up for DigitalOcean
- [ ] Created app from GitHub
- [ ] Set root directory to `backend`
- [ ] Added PostgreSQL database
- [ ] Set environment variables:
  - [ ] `SECRET_KEY`
  - [ ] `REDIS_URL` (from Upstash)
  - [ ] `CORS_ORIGINS=*`
  - [ ] `ENVIRONMENT=production`
- [ ] Deployed successfully
- [ ] Tested health endpoint
- [ ] Updated mobile app URL
- [ ] Rebuilt APK

---

## 🆘 Troubleshooting

### Build Fails

**Check:**
- Root directory is `backend`
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
- `DATABASE_URL` is set automatically
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

**Paid Plans:**
- Basic: $5/month
- Professional: $12/month
- Scales with usage

---

## 🎯 Summary

✅ **Easiest deployment option**  
✅ **No CLI needed**  
✅ **Auto-detects Python/FastAPI**  
✅ **PostgreSQL included**  
✅ **~10 minutes setup**  

**Your app will be live at:** `https://your-app-name-xxxxx.ondigitalocean.app` 🚀
