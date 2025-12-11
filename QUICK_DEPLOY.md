# Quick Deploy to Railway 🚀

## ⚡ 5-Minute Deployment

### 1. Open Railway
👉 https://railway.app/dashboard

### 2. Add PostgreSQL
- Click **"+"** → **"Database"** → **"Add PostgreSQL"**
- Wait ~30 seconds

### 3. Add Backend
- Click **"+"** → **"GitHub Repo"** (or "Empty Service")
- Connect your repo or upload files

### 4. Set Variables
Go to service → **"Variables"** tab:
```
JWT_SECRET=<generate token>
CORS_ORIGINS=*
ENVIRONMENT=production
```

### 5. Deploy
- Railway auto-deploys
- Watch in "Deployments" tab

### 6. Get URL
- Service → **"Settings"** → **"Domains"**
- Click **"Generate Domain"**
- Copy URL

### 7. Update App
```bash
./scripts/update_railway_url.sh https://YOUR-URL.railway.app
```

### 8. Rebuild APK
```bash
cd mobile && flutter build apk --release
```

## ✅ Done!

**Full guide:** `RAILWAY_DEPLOY_NOW.md`  
**Checklist:** `DEPLOY_CHECKLIST.md`

---

**Start at step 1: Open Railway dashboard!** 🚀



