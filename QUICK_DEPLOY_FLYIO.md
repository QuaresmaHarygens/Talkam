# Quick Deploy to Fly.io (15 Minutes) 🚀

## 🎯 Why Fly.io?

- ✅ **Free tier** - Generous limits
- ✅ **Fast global network** - Edge locations
- ✅ **Works with pyproject.toml** - No issues
- ✅ **Great performance** - Fast deployments
- ✅ **Good docs** - Easy to follow

---

## 📋 Step-by-Step Guide

### Step 1: Install Fly CLI

**macOS:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Or download:** https://fly.io/docs/hands-on/install-flyctl/

**Verify:**
```bash
fly version
```

### Step 2: Login

```bash
fly auth login
```

**Opens browser to authenticate**

### Step 3: Initialize App

```bash
cd backend
fly launch
```

**Follow prompts:**
- App name: `talkam-backend` (or auto-generated)
- Region: Choose closest (e.g., `iad` for US East)
- PostgreSQL: Say "yes" (or add later)
- Redis: Say "no" (or add if needed)

**This creates `fly.toml` config file**

### Step 4: Add PostgreSQL (If Not Added)

**If you didn't add PostgreSQL during launch:**

```bash
fly postgres create --name talkam-db
```

**Attach to app:**
```bash
fly postgres attach talkam-db
```

**This automatically:**
- Sets `DATABASE_URL` environment variable
- Links database to your app

### Step 5: Set Secrets (Environment Variables)

```bash
# Generate JWT secret
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'

# Set secrets
fly secrets set JWT_SECRET="your-generated-secret"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

**View secrets:**
```bash
fly secrets list
```

### Step 6: Configure fly.toml (If Needed)

**Check `backend/fly.toml`:**

**Should have:**
```toml
[build]
  builder = "paketobuildpacks/builder:base"

[env]
  PORT = "8080"

[[services]]
  http_checks = []
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
  script_checks = []
```

**Update if needed:**
- Make sure port matches your app
- Update start command if needed

### Step 7: Deploy

```bash
fly deploy
```

**Watch deployment:**
- Builds your app
- Installs dependencies
- Deploys to Fly.io
- Shows URL when done

### Step 8: Get Your URL

**After deployment:**
```bash
fly status
```

**Or check dashboard:** https://fly.io/dashboard

**URL format:** `https://your-app.fly.dev`

### Step 9: Test Deployment

**Test your service:**
```bash
curl https://your-app.fly.dev/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

### Step 10: Update Mobile App

**Update mobile app:**
```bash
./scripts/update_railway_url.sh https://your-app.fly.dev
```

**Rebuild APK:**
```bash
cd mobile && flutter build apk --release
```

---

## ✅ Checklist

- [ ] Fly CLI installed
- [ ] Logged in to Fly.io
- [ ] App initialized (`fly launch`)
- [ ] PostgreSQL database created
- [ ] Database attached to app
- [ ] Secrets set (JWT_SECRET, CORS_ORIGINS, ENVIRONMENT)
- [ ] App deployed (`fly deploy`)
- [ ] Health endpoint tested
- [ ] Mobile app updated
- [ ] APK rebuilt

---

## 🆘 Troubleshooting

### Deployment Fails

**Check logs:**
```bash
fly logs
```

**Redeploy:**
```bash
fly deploy
```

### Database Not Connected

**Check:**
```bash
fly postgres list
fly postgres attach <db-name>
```

### Secrets Not Set

**Check:**
```bash
fly secrets list
```

**Set again if missing**

---

## 💰 Pricing

**Free Tier:**
- 3 shared-cpu-1x VMs
- 3GB persistent volume storage
- 160GB outbound data transfer
- **Perfect for testing!**

**Paid:**
- Starts at ~$2/month per VM
- Very affordable

---

## 🎯 Why Fly.io is Better

**Compared to Render:**
- ✅ No build detection issues
- ✅ Works with pyproject.toml
- ✅ Fast global network
- ✅ Better free tier
- ✅ More reliable

---

**Fly.io is a great alternative - try it now!** 🚀

**Install:** `curl -L https://fly.io/install.sh | sh`

