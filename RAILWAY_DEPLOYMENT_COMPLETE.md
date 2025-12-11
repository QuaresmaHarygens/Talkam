# Railway Deployment - Complete Guide 🚀

## 🎯 Two Paths Forward

### Path A: Deploy to Railway First

**If you haven't deployed yet:**

1. **Open Railway Dashboard:**
   - Go to: https://railway.app/dashboard
   - Login (or create account)

2. **Follow the deployment guide:**
   - Read: `START_DEPLOYMENT.md` (quick checklist)
   - Or: `DEPLOY_NOW_STEP_BY_STEP.md` (detailed steps)

3. **Quick deployment steps:**
   - Add PostgreSQL database
   - Add backend service (GitHub repo recommended)
   - Set environment variables:
     - `JWT_SECRET`: `NaJ4Cehv5UPAJNeJut3JLXoNysFhSl8y1AspwSiVhJo`
     - `CORS_ORIGINS`: `*`
     - `ENVIRONMENT`: `production`
   - Deploy and get Railway URL

4. **Then proceed to Path B below**

---

### Path B: Update App with Railway URL

**If you already have a Railway URL:**

**Option 1: Automated (Recommended)**

```bash
./scripts/complete_railway_deployment.sh https://YOUR-URL.railway.app
```

**This script will:**
- ✅ Verify deployment (test health endpoint)
- ✅ Update mobile app with Railway URL
- ✅ Rebuild APK automatically
- ✅ Show you where the APK is

**Option 2: Manual Steps**

**Step 1: Verify Deployment**
```bash
./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app
```

**Step 2: Update Mobile App**
```bash
./scripts/update_railway_url.sh https://YOUR-URL.railway.app
```

**Step 3: Rebuild APK**
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

## 📋 Complete Checklist

### Pre-Deployment
- [x] Railway config files created
- [x] Procfile with auto-migrations
- [x] DATABASE_URL support added
- [x] Helper scripts created
- [x] JWT secret generated

### Deployment
- [ ] PostgreSQL database added in Railway
- [ ] Backend service created
- [ ] Environment variables set
- [ ] Service deployed successfully
- [ ] Railway URL obtained

### Post-Deployment
- [ ] Deployment verified (health check)
- [ ] Mobile app updated with Railway URL
- [ ] APK rebuilt
- [ ] APK tested on device
- [ ] All features working
- [ ] APK shared with users

---

## 🚀 Quick Start Commands

**If you have Railway URL:**

```bash
# Complete automation (recommended)
./scripts/complete_railway_deployment.sh https://YOUR-URL.railway.app
```

**Or step by step:**

```bash
# 1. Verify
./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app

# 2. Update app
./scripts/update_railway_url.sh https://YOUR-URL.railway.app

# 3. Rebuild
cd mobile && flutter build apk --release
```

---

## 🔑 Environment Variables Reference

**Required in Railway:**
- `DATABASE_URL` - Auto-set by PostgreSQL service
- `JWT_SECRET` - `NaJ4Cehv5UPAJNeJut3JLXoNysFhSl8y1AspwSiVhJo`
- `CORS_ORIGINS` - `*`
- `ENVIRONMENT` - `production`
- `PORT` - Auto-set by Railway

**See:** `RAILWAY_ENV_VARS.md` for complete reference

---

## 🆘 Troubleshooting

### Deployment Fails

**Check Railway logs:**
1. Railway dashboard → Service → Deployments → Latest → Logs
2. Look for error messages
3. Common issues:
   - Missing environment variables
   - Wrong Start Command
   - Build errors

### Health Check Fails

**Test manually:**
```bash
curl https://YOUR-URL.railway.app/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

**If it fails:**
- Check Railway logs
- Verify service is running
- Check environment variables

### App Can't Connect

**Verify:**
1. Railway URL is correct in `mobile/lib/providers.dart`
2. Health endpoint works in browser
3. CORS_ORIGINS is set to `*`
4. Rebuild APK after URL change

---

## ✅ Success Indicators

**You're done when:**
- ✅ Railway service is running
- ✅ Health endpoint returns 200
- ✅ Mobile app updated with Railway URL
- ✅ APK rebuilt successfully
- ✅ APK works on device
- ✅ All features functional

---

## 📚 Related Guides

- `START_DEPLOYMENT.md` - Quick deployment checklist
- `DEPLOY_NOW_STEP_BY_STEP.md` - Detailed step-by-step
- `NEXT_STEPS.md` - Status check and next actions
- `RAILWAY_ENV_VARS.md` - Environment variables reference

---

## 🎯 Current Status

**Your app is currently using:** LocalTunnel URL

**Next action:**
1. **If not deployed:** Follow Path A above
2. **If deployed:** Run the complete deployment script with your Railway URL

---

**Ready to deploy? Follow Path A. Have Railway URL? Follow Path B!** 🚀

