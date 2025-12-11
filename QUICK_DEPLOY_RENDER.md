# Quick Deploy to Render (10 Minutes) ⚡

## 🎯 Why Render?

- ✅ **Free tier** - Perfect for testing
- ✅ **Auto-deploys** from GitHub
- ✅ **PostgreSQL included** - Easy database setup
- ✅ **Simple interface** - No CLI needed
- ✅ **Fast setup** - 10 minutes

---

## 📋 Step-by-Step Guide

### Step 1: Sign Up

1. **Go to:** https://render.com
2. **Click "Get Started"**
3. **Sign up** (GitHub, Google, or email)
4. **Verify email** (if needed)

### Step 2: Create Web Service

1. **Click "New +"** → **"Web Service"**
2. **Connect GitHub:**
   - Click "Connect GitHub"
   - Authorize Render
   - Select your repository

3. **Configure Service:**
   - **Name:** `talkam-backend` (or any name)
   - **Region:** Choose closest to you
   - **Branch:** `main` (or your branch)
   - **Root Directory:** `backend`
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -e .`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

4. **Click "Create Web Service"**

### Step 3: Add PostgreSQL Database

1. **Click "New +"** → **"PostgreSQL"**
2. **Configure:**
   - **Name:** `talkam-db` (or any name)
   - **Region:** Same as web service
   - **Plan:** Free (for testing)
3. **Click "Create Database"**
4. **Copy the Internal Database URL** (you'll need it)

### Step 4: Link Database to Service

1. **Go to your web service**
2. **Go to "Environment" tab**
3. **Add Environment Variable:**
   - **Key:** `DATABASE_URL`
   - **Value:** Paste the database URL from Step 3
   - **Click "Save Changes"**

**Or:** Render can auto-link if services are in same project.

### Step 5: Set Environment Variables

**In your web service → "Environment" tab:**

1. **Add `JWT_SECRET`:**
   - Generate: `python3 -c 'import secrets; print(secrets.token_urlsafe(32))'`
   - Copy the output
   - Add as environment variable

2. **Add `CORS_ORIGINS`:**
   - Value: `*`

3. **Add `ENVIRONMENT`:**
   - Value: `production`

4. **Add `REDIS_URL` (optional):**
   - If you have Redis, add the URL

5. **Click "Save Changes"**

### Step 6: Deploy

1. **Render auto-deploys** when you save
2. **Go to "Events" tab** to watch deployment
3. **Wait for:** "Deploy successful"

### Step 7: Get Your URL

1. **Go to your web service**
2. **At the top, you'll see your URL:**
   - Example: `https://talkam-backend.onrender.com`
3. **Copy this URL**

### Step 8: Test Deployment

**Test health endpoint:**
```bash
curl https://your-app.onrender.com/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

### Step 9: Update Mobile App

**Update mobile app with Render URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app.onrender.com
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://your-app.onrender.com/v1',
```

### Step 10: Rebuild APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

**APK Location:**
```
mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Checklist

- [ ] Signed up for Render
- [ ] Created web service
- [ ] Connected GitHub repo
- [ ] Set root directory to `backend`
- [ ] Set build command: `pip install -e .`
- [ ] Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- [ ] Created PostgreSQL database
- [ ] Linked database to service
- [ ] Set environment variables (JWT_SECRET, CORS_ORIGINS, ENVIRONMENT)
- [ ] Service deployed successfully
- [ ] Health endpoint tested
- [ ] Mobile app updated with Render URL
- [ ] APK rebuilt

---

## 🆘 Troubleshooting

### Deployment Fails

**Check:**
- Build logs in Render dashboard
- Verify build command is correct
- Check Python version (should be 3.9+)
- Verify `pyproject.toml` is in `backend/` folder

### Database Connection Error

**Check:**
- `DATABASE_URL` is set correctly
- Database is in same region as service
- Database is running (not paused)

### Service Returns 404

**Check:**
- Service is deployed (not building)
- Start command is correct
- Check service logs for errors

### CORS Errors

**Check:**
- `CORS_ORIGINS` is set to `*` (for testing)
- Or set to specific domain

---

## 🎯 Quick Commands

**After deployment:**

```bash
# Test service
curl https://your-app.onrender.com/v1/health

# Update mobile app
./scripts/update_railway_url.sh https://your-app.onrender.com

# Rebuild APK
cd mobile && flutter build apk --release
```

---

## 📝 Notes

- **Free tier:** Services sleep after 15 min inactivity (wake up on first request)
- **Upgrade:** For always-on, upgrade to paid plan
- **Custom domain:** Can add custom domain in settings
- **Logs:** View logs in Render dashboard

---

**Render is the easiest alternative to Railway!** 🚀

**Start here:** https://render.com

