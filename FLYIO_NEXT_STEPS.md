# Fly.io Next Steps - Continue Setup 🚀

## 🎯 Current Status

**Setting up Fly.io deployment**

---

## Step 1: Verify Fly CLI Installation

**Check if Fly CLI is installed:**
```bash
fly version
```

**If not installed, run:**
```bash
curl -L https://fly.io/install.sh | sh
export PATH="$HOME/.fly/bin:$PATH"
```

---

## Step 2: Login to Fly.io

**Authenticate with Fly.io:**
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

**Verify login:**
```bash
fly auth whoami
```

---

## Step 3: Initialize Your App

**Navigate to backend and initialize:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
fly launch
```

**Follow the prompts:**

1. **App name:**
   - Enter: `talkam-backend` (or press Enter for auto-generated)
   - Must be globally unique

2. **Organization:**
   - Select your personal org

3. **Region:**
   - Choose closest to you
   - Examples: `iad` (US East), `sjc` (US West), `lhr` (London)

4. **PostgreSQL:**
   - **Say "yes"** to create PostgreSQL database
   - This auto-sets `DATABASE_URL`

5. **Redis:**
   - Say "no" (unless you need it)

6. **Deploy now:**
   - Say "no" (we'll configure secrets first)
   - Or "yes" if you want to deploy immediately

**This creates `fly.toml` config file**

---

## Step 4: Add PostgreSQL (If Not Added During Launch)

**If you said "no" to PostgreSQL:**

```bash
# Create database
fly postgres create --name talkam-db --region iad

# Attach to your app
fly postgres attach talkam-db
```

**Verify it's attached:**
```bash
fly secrets list
```

**Should see:** `DATABASE_URL`

---

## Step 5: Set Environment Variables (Secrets)

**Generate JWT secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

**Set secrets:**
```bash
fly secrets set JWT_SECRET="paste-your-generated-secret-here"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"
```

**View all secrets:**
```bash
fly secrets list
```

**Should show:**
- `DATABASE_URL` (auto-set by PostgreSQL)
- `JWT_SECRET`
- `CORS_ORIGINS`
- `ENVIRONMENT`

---

## Step 6: Review fly.toml Configuration

**Check the generated `backend/fly.toml`:**

**Should have:**
```toml
app = "talkam-backend"
primary_region = "iad"

[build]

[env]
  PORT = "8080"

[[services]]
  internal_port = 8080
  processes = ["app"]
  protocol = "tcp"
```

**If you need to customize, add:**
```toml
[build]
  builder = "paketobuildpacks/builder:base"

[[services.http_checks]]
  interval = "10s"
  timeout = "2s"
  grace_period = "5s"
  method = "GET"
  path = "/v1/health"
```

---

## Step 7: Deploy Your App

**Deploy to Fly.io:**
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

## Step 8: Get Your URL

**After successful deployment:**

```bash
fly status
```

**Or check dashboard:** https://fly.io/dashboard

**URL format:** `https://talkam-backend.fly.dev`

---

## Step 9: Test Deployment

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

## Step 10: Update Mobile App

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

## Step 11: Rebuild APK

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

## ✅ Quick Command Reference

```bash
# Check installation
fly version

# Login
fly auth login

# Initialize app
cd backend && fly launch

# Create database (if needed)
fly postgres create --name talkam-db

# Attach database
fly postgres attach talkam-db

# Set secrets
fly secrets set JWT_SECRET="your-secret"
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

## 🆘 Troubleshooting

### Fly CLI Not Found

**Add to PATH:**
```bash
export PATH="$HOME/.fly/bin:$PATH"
```

**Or add to `~/.zshrc`:**
```bash
echo 'export PATH="$HOME/.fly/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Login Fails

**Try:**
```bash
fly auth login --web
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

---

## 📝 Your Generated JWT Secret

**Use this for Step 5:**
```
[Will be generated when you run the command]
```

**Or generate your own:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

---

**Follow these steps to complete Fly.io setup!** 🚀

