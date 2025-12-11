# Railway Project Linked - Next Steps 🚀

## ✅ Project Linked

**Your backend is now linked to Railway project!**

## 📋 Next Steps

### Step 1: Add PostgreSQL Database

**Railway provides free PostgreSQL:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
railway add postgresql
```

**This automatically:**
- Creates PostgreSQL database
- Sets `DATABASE_URL` environment variable
- No configuration needed!

### Step 2: Set Environment Variables

**Set required variables:**

```bash
# Generate JWT secret
JWT_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')

# Set variables
railway variables set JWT_SECRET="$JWT_SECRET"
railway variables set CORS_ORIGINS="*"
railway variables set ENVIRONMENT="production"
```

**Or set via Railway dashboard:**
- Go to: https://railway.app/dashboard
- Click your project
- Go to Variables tab
- Add variables

### Step 3: Deploy

```bash
railway up
```

**Railway will:**
- Build your app
- Install dependencies
- Deploy to cloud
- Provide URL

### Step 4: Get Your URL

```bash
railway domain
```

**You'll get a URL like:** `https://your-app.railway.app`

**Save this URL!**

### Step 5: Run Database Migrations

```bash
railway run alembic upgrade head
```

**This creates all database tables.**

### Step 6: Seed Test Data (Optional)

```bash
railway run python scripts/seed_data.py
```

**This creates test users and data.**

### Step 7: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-RAILWAY-URL.railway.app/v1',  // Your Railway URL
));
```

### Step 8: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

### Step 9: Share APK!

**Now you can share the APK with remote users:**
- Works from anywhere
- No network setup needed
- Permanent URL
- Professional solution

## 🔍 Verify Deployment

**Test your deployed backend:**

```bash
# Get URL
railway domain

# Test health endpoint
curl https://your-app.railway.app/health

# Should return: {"status":"healthy","service":"talkam-api"}
```

## 📋 Required Environment Variables

**Set these in Railway:**

- [ ] `DATABASE_URL` (auto-set by PostgreSQL service)
- [ ] `JWT_SECRET` (random 32+ character string)
- [ ] `CORS_ORIGINS` (set to `*` for mobile app)
- [ ] `REDIS_URL` (optional - can add Redis service)
- [ ] `ENVIRONMENT` (set to `production`)

## ✅ Quick Command Summary

```bash
# 1. Link project (already done)
railway link -p d83eed38-27e4-4539-bd80-431d789d0c97

# 2. Add database
railway add postgresql

# 3. Set variables
railway variables set JWT_SECRET="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
railway variables set CORS_ORIGINS="*"

# 4. Deploy
railway up

# 5. Get URL
railway domain

# 6. Run migrations
railway run alembic upgrade head
```

---

**Follow these steps to complete deployment!** 🚀



