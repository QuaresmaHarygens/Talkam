# Railway Deployment - Next Steps 🚀

## ✅ Current Status

**Railway Configuration Ready:**
- ✅ `backend/railway.json` - Railway config
- ✅ `backend/Procfile` - Process config (includes auto-migrations)
- ✅ Backend code ready for deployment

**Mobile App:**
- ⏳ Currently using LocalTunnel URL
- ⏳ Ready to update with Railway URL

## 📋 Deployment Steps

### Step 1: Deploy via Railway Dashboard

**Go to:** https://railway.app/dashboard

1. **Add PostgreSQL:**
   - Click "New" → "Database" → "Add PostgreSQL"
   - Railway sets `DATABASE_URL` automatically

2. **Add Backend Service:**
   - Click "New" → "GitHub Repo" (or "Empty Service")
   - Connect your repository or upload `backend/` folder
   - Railway auto-detects Python/FastAPI

3. **Set Environment Variables:**
   - Go to service → "Variables" tab
   - Add:
     ```
     JWT_SECRET=<generate with: python3 -c 'import secrets; print(secrets.token_urlsafe(32))'>
     CORS_ORIGINS=*
     ENVIRONMENT=production
     ```

4. **Deploy:**
   - Railway auto-deploys
   - Watch in "Deployments" tab

5. **Get URL:**
   - Service → "Settings" → "Domains"
   - Click "Generate Domain"
   - Copy URL (e.g., `https://talkam-api.railway.app`)

### Step 2: Verify Deployment

**Run verification script:**
```bash
chmod +x scripts/verify_railway_deployment.sh
./scripts/verify_railway_deployment.sh https://YOUR-RAILWAY-URL.railway.app
```

**Or test manually:**
```bash
curl https://YOUR-RAILWAY-URL.railway.app/health
# Should return: {"status":"healthy","service":"talkam-api"}
```

### Step 3: Update Mobile App

**Option A: Use Script (Recommended)**
```bash
chmod +x scripts/update_railway_url.sh
./scripts/update_railway_url.sh https://YOUR-RAILWAY-URL.railway.app
```

**Option B: Manual Update**
Edit `mobile/lib/providers.dart`:
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-RAILWAY-URL.railway.app/v1',
));
```

### Step 4: Rebuild APK

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

### Step 5: Test & Share

1. **Install APK on device**
2. **Test all features:**
   - Login/Register
   - Submit reports
   - Upload media
   - View dashboard
3. **Share APK** with users

## 🔧 Helper Scripts

**Update App URL:**
```bash
./scripts/update_railway_url.sh <RAILWAY_URL>
```

**Verify Deployment:**
```bash
./scripts/verify_railway_deployment.sh <RAILWAY_URL>
```

## 📝 Environment Variables Checklist

**Required in Railway:**
- ✅ `DATABASE_URL` (auto-set by PostgreSQL service)
- ✅ `JWT_SECRET` (generate secure token)
- ✅ `CORS_ORIGINS` (set to `*` for now)
- ✅ `ENVIRONMENT` (set to `production`)
- ✅ `PORT` (auto-set by Railway)

**Optional:**
- `REDIS_URL` (if using Redis)
- `S3_ENDPOINT` (for media storage)
- `SMS_GATEWAY_URL` (for SMS)

## 🎯 Quick Commands

**After getting Railway URL:**

```bash
# 1. Verify deployment
./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app

# 2. Update app
./scripts/update_railway_url.sh https://YOUR-URL.railway.app

# 3. Rebuild APK
cd mobile && flutter build apk --release

# 4. APK ready!
# Location: mobile/build/app/outputs/flutter-apk/app-release.apk
```

## ✅ Deployment Checklist

- [ ] PostgreSQL database added in Railway
- [ ] Backend service created and deployed
- [ ] Environment variables set
- [ ] Deployment successful (check logs)
- [ ] Railway URL obtained
- [ ] Health endpoint tested (`/health`)
- [ ] API docs accessible (`/docs`)
- [ ] Mobile app updated with Railway URL
- [ ] APK rebuilt with new URL
- [ ] APK tested on device
- [ ] All features working
- [ ] APK shared with users

## 🆘 Troubleshooting

**Deployment fails:**
- Check Railway logs in dashboard
- Verify environment variables
- Check `railway.json` and `Procfile`

**Migrations not running:**
- Check `Procfile` has: `release: alembic upgrade head || true`
- Or run manually in Railway terminal

**App can't connect:**
- Verify Railway URL is correct
- Check CORS settings (`CORS_ORIGINS=*`)
- Test health endpoint in browser

**Need help?**
- Railway docs: https://docs.railway.app
- Check logs in Railway dashboard

---

**Once you have Railway URL, run the update script and rebuild APK!** 🚀



