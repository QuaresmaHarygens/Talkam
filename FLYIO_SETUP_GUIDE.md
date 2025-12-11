# Fly.io Setup Guide - Step by Step 🚀

## 🎯 Current Step: Setting Up Fly.io

Follow these steps in order:

---

## Step 1: Install Fly CLI

**macOS:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Or download:** https://fly.io/docs/hands-on/install-flyctl/

**Verify installation:**
```bash
fly version
```

**Should show:** `flyctl vX.X.X`

---

## Step 2: Login to Fly.io

```bash
fly auth login
```

**This will:**
- Open browser for authentication
- Create/use Fly.io account
- Link CLI to your account

**If browser doesn't open:**
```bash
fly auth login --web
```

---

## Step 3: Initialize Your App

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly launch
```

**Follow the prompts:**

1. **App name:** 
   - Enter: `talkam-backend` (or press Enter for auto-generated)
   - Must be unique globally

2. **Organization:**
   - Select your personal org (or create one)

3. **Region:**
   - Choose closest to you
   - Examples: `iad` (US East), `sjc` (US West), `lhr` (London)

4. **PostgreSQL:**
   - **Say "yes"** to create PostgreSQL database
   - Or "no" and add later

5. **Redis:**
   - Say "no" (unless you need it)

6. **Deploy now:**
   - Say "no" (we'll configure first)
   - Or "yes" to deploy immediately

**This creates `fly.toml` config file**

---

## Step 4: Review fly.toml

**Check the generated `backend/fly.toml`:**

**Should have sections like:**
```toml
app = "talkam-backend"
primary_region = "iad"

[build]

[env]
  PORT = "8080"

[[services]]
  internal_port = 8080
  protocol = "tcp"
```

**If port is wrong, update it to match your app**

---

## Step 5: Add PostgreSQL (If Not Added)

**If you said "no" to PostgreSQL during launch:**

```bash
# Create database
fly postgres create --name talkam-db --region iad

# Attach to your app
fly postgres attach talkam-db
```

**This automatically:**
- Sets `DATABASE_URL` environment variable
- Links database to your app

**Check it's attached:**
```bash
fly secrets list
```

**Should see:** `DATABASE_URL`

---

## Step 6: Set Environment Variables (Secrets)

**Generate JWT secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Set secrets:**
```bash
fly secrets set JWT_SECRET="paste-generated-secret-here"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

**View all secrets:**
```bash
fly secrets list
```

---

## Step 7: Configure fly.toml (If Needed)

**Check `backend/fly.toml` for start command:**

**Should have or add:**
```toml
[build]
  builder = "paketobuildpacks/builder:base"

[env]
  PORT = "8080"

[[services]]
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
  
  [services.concurrency]
    type = "requests"
    hard_limit = 25
    soft_limit = 20

  [[services.http_checks]]
    interval = "10s"
    timeout = "2s"
    grace_period = "5s"
    method = "GET"
    path = "/v1/health"
```

**Or use Procfile approach** (if you have one)

---

## Step 8: Deploy

```bash
fly deploy
```

**Watch the deployment:**
- Builds your app
- Installs dependencies from pyproject.toml
- Deploys to Fly.io
- Shows URL when done

**If deployment fails:**
```bash
fly logs
```

**To see what went wrong**

---

## Step 9: Get Your URL

**After successful deployment:**

```bash
fly status
```

**Or check dashboard:** https://fly.io/dashboard

**URL format:** `https://talkam-backend.fly.dev`

---

## Step 10: Test Deployment

**Test health endpoint:**
```bash
curl https://your-app.fly.dev/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Test in browser:**
- Open: `https://your-app.fly.dev/docs`
- Should show FastAPI documentation

---

## Step 11: Update Mobile App

**Once service is working:**

```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://your-app.fly.dev
```

**Or manually edit:** `mobile/lib/providers.dart`
```dart
baseUrl: 'https://your-app.fly.dev/v1',
```

---

## Step 12: Rebuild APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## ✅ Checklist

- [ ] Fly CLI installed (`fly version`)
- [ ] Logged in (`fly auth login`)
- [ ] App initialized (`fly launch`)
- [ ] PostgreSQL database created
- [ ] Database attached to app
- [ ] Secrets set (JWT_SECRET, CORS_ORIGINS, ENVIRONMENT)
- [ ] fly.toml configured correctly
- [ ] App deployed (`fly deploy`)
- [ ] Health endpoint tested
- [ ] Mobile app updated with Fly.io URL
- [ ] APK rebuilt

---

## 🆘 Troubleshooting

### Fly CLI Not Found

**After installing, add to PATH:**
```bash
export PATH="$HOME/.fly/bin:$PATH"
```

**Or add to `~/.zshrc`:**
```bash
echo 'export PATH="$HOME/.fly/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Deployment Fails

**Check logs:**
```bash
fly logs
```

**Common issues:**
- Dependencies not installing
- Wrong start command
- Missing environment variables

### Database Not Connected

**Check:**
```bash
fly postgres list
fly postgres attach <db-name>
fly secrets list  # Should see DATABASE_URL
```

### App Won't Start

**Check:**
```bash
fly status
fly logs
```

**Verify:**
- Start command is correct
- Port matches fly.toml
- Environment variables are set

---

## 📝 Quick Commands Reference

```bash
# Install
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Initialize
cd backend && fly launch

# Create database
fly postgres create --name talkam-db

# Attach database
fly postgres attach talkam-db

# Set secrets
fly secrets set JWT_SECRET="..."
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"

# Deploy
fly deploy

# Check status
fly status

# View logs
fly logs

# List secrets
fly secrets list
```

---

## 🎯 Next Steps

**You're at Step 1: Install Fly CLI**

**Run:**
```bash
curl -L https://fly.io/install.sh | sh
```

**Then continue with the steps above!**

---

**Follow these steps and you'll be deployed on Fly.io!** 🚀

