# Railway Setup - Complete Guide 🚀

## ✅ Project Linked

**Your Railway project is linked!**

## 📋 Complete Setup Steps

### Step 1: Install Railway CLI (If Not Installed)

```bash
brew install railway
```

### Step 2: Link Project (Already Done)

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
railway link -p d83eed38-27e4-4539-bd80-431d789d0c97
```

### Step 3: Add PostgreSQL Database

**Railway provides free PostgreSQL:**

```bash
railway add postgresql
```

**This automatically:**
- Creates PostgreSQL database
- Sets `DATABASE_URL` environment variable
- Connects to your project

### Step 4: Set Environment Variables

**Generate and set JWT secret:**

```bash
# Generate secret
JWT_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')

# Set in Railway
railway variables set JWT_SECRET="$JWT_SECRET"
railway variables set CORS_ORIGINS="*"
railway variables set ENVIRONMENT="production"
```

**Or set via Railway dashboard:**
1. Go to: https://railway.app/dashboard
2. Click your project
3. Go to **Variables** tab
4. Add:
   - `JWT_SECRET`: (generate random 32+ char string)
   - `CORS_ORIGINS`: `*`
   - `ENVIRONMENT`: `production`

### Step 5: Deploy

```bash
railway up
```

**Railway will:**
- Build your app
- Install dependencies from `pyproject.toml`
- Deploy to cloud
- Show deployment URL

### Step 6: Get Your URL

```bash
railway domain
```

**You'll get a URL like:** `https://talkam-api.railway.app`

**📋 Save this URL - you'll need it for the app!**

### Step 7: Run Database Migrations

```bash
railway run alembic upgrade head
```

**This creates all database tables.**

### Step 8: Seed Test Data (Optional)

```bash
railway run python scripts/seed_data.py
```

**This creates test users:**
- Admin: `231770000001` / `AdminPass123!`
- User: `231770000003` / `UserPass123!`

### Step 9: Verify Deployment

**Test your deployed backend:**

```bash
# Get URL
railway domain

# Test health endpoint
curl https://your-app.railway.app/health

# Should return: {"status":"healthy","service":"talkam-api"}
```

### Step 10: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-RAILWAY-URL.railway.app/v1',  // Your Railway URL
));
```

**Replace `YOUR-RAILWAY-URL` with your actual Railway domain.**

### Step 11: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

### Step 12: Share APK!

**Now you can share the APK with remote users:**
- Works from anywhere in the world
- No network setup needed
- Permanent URL
- Professional solution

## 🔍 Check Project Status

**View project details:**

```bash
railway status
railway domain
railway variables
```

## 📋 Environment Variables Checklist

**Required:**
- [ ] `DATABASE_URL` (auto-set by PostgreSQL)
- [ ] `JWT_SECRET` (32+ character random string)
- [ ] `CORS_ORIGINS` (set to `*`)

**Optional:**
- [ ] `REDIS_URL` (add Redis service if needed)
- [ ] `S3_ENDPOINT` (for media storage)
- [ ] `SMS_GATEWAY_URL` (for SMS)
- [ ] `ENVIRONMENT` (set to `production`)

## ✅ Quick Command Reference

```bash
# Link project
railway link -p d83eed38-27e4-4539-bd80-431d789d0c97

# Add database
railway add postgresql

# Set variables
railway variables set JWT_SECRET="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
railway variables set CORS_ORIGINS="*"

# Deploy
railway up

# Get URL
railway domain

# Run migrations
railway run alembic upgrade head

# Seed data (optional)
railway run python scripts/seed_data.py
```

## 🎯 After Deployment

**Once deployed:**
1. ✅ Get Railway URL
2. ✅ Update app with Railway URL
3. ✅ Rebuild APK
4. ✅ Share APK - works for remote users!

---

**Follow these steps to complete Railway deployment!** 🚀



