# ✅ DigitalOcean Setup Checklist

## 🔑 Your Configuration Values

**SECRET_KEY:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Environment Variables to Set:**
- `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- `REDIS_URL` = (Get from Upstash - see Step 5)
- `CORS_ORIGINS` = `*`
- `ENVIRONMENT` = `production`
- `DATABASE_URL` = (Auto-set by DigitalOcean)

---

## 📋 Step-by-Step Checklist

### Step 1: Sign Up ✅
- [ ] Go to https://cloud.digitalocean.com
- [ ] Create account
- [ ] Verify email
- [ ] Get $5 free credit

### Step 2: Create App ✅
- [ ] Click "Create" → "App"
- [ ] Connect GitHub
- [ ] Select repository: `QuaresmaHarygens/Talkam`
- [ ] Select branch: `main`

### Step 3: Configure App ✅
- [ ] Root Directory: `backend` ⚠️ **CRITICAL**
- [ ] Build Command: `pip install -e .`
- [ ] Run Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- [ ] Click "Next"

### Step 4: Add PostgreSQL ✅
- [ ] Click "Add Resource" → "Database"
- [ ] Select PostgreSQL
- [ ] Choose plan (Dev $7/month or Basic $15/month)
- [ ] Database name: `talkam-db`
- [ ] Click "Add Database"
- [ ] `DATABASE_URL` auto-set ✅

### Step 5: Set Up Redis (Upstash) ✅
- [ ] Go to https://console.upstash.com
- [ ] Sign up (free)
- [ ] Create database: `talkam-redis`
- [ ] Type: Regional
- [ ] Region: Choose closest
- [ ] Copy Redis URL
- [ ] Save Redis URL for Step 6

### Step 6: Set Environment Variables ✅
- [ ] Go to "Settings" → "Environment Variables"
- [ ] Add `SECRET_KEY` = `9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`
- [ ] Add `REDIS_URL` = (from Upstash)
- [ ] Add `CORS_ORIGINS` = `*`
- [ ] Add `ENVIRONMENT` = `production`
- [ ] Verify `DATABASE_URL` is set (auto-set)
- [ ] Click "Save"

### Step 7: Deploy ✅
- [ ] Click "Deploy" or "Save"
- [ ] Wait for build (~5-10 minutes)
- [ ] Watch deployment logs
- [ ] Verify build succeeds
- [ ] Get deployment URL

### Step 8: Test Deployment ✅
- [ ] Test health: `curl https://your-app.ondigitalocean.app/health`
- [ ] Test docs: Open `https://your-app.ondigitalocean.app/docs`
- [ ] Verify response: `{"status":"healthy","service":"talkam-api"}`

### Step 9: Update Mobile App ✅
- [ ] Run: `./scripts/update_railway_url.sh https://your-app.ondigitalocean.app`
- [ ] Or manually edit `mobile/lib/providers.dart`
- [ ] Rebuild APK: `cd mobile && flutter build apk --release`

---

## 🎯 Quick Reference

**DigitalOcean Dashboard:**
https://cloud.digitalocean.com

**Upstash Console:**
https://console.upstash.com

**Your Secret Key:**
`9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4`

**Build Command:**
`pip install -e .`

**Run Command:**
`uvicorn app.main:app --host 0.0.0.0 --port $PORT`

**Root Directory:**
`backend`

---

## 🆘 If Something Goes Wrong

**Build Fails:**
- Check root directory is `backend`
- Verify build command: `pip install -e .`
- Check logs in "Runtime Logs"

**App Won't Start:**
- Check environment variables are set
- Verify `DATABASE_URL` is set
- Check "Runtime Logs" for errors

**Database Connection Fails:**
- Verify `DATABASE_URL` is auto-set
- Check database is running
- Verify connection string format

---

## 📝 Notes

- DigitalOcean auto-sets `DATABASE_URL` when you add PostgreSQL
- Use Upstash for free Redis (no credit card needed)
- App URL format: `https://your-app-name-xxxxx.ondigitalocean.app`
- Deployment takes ~5-10 minutes
- Free $5 credit monthly covers small apps

---

**Ready to start? Follow DIGITALOCEAN_DEPLOY_NOW.md step by step!** 🚀
