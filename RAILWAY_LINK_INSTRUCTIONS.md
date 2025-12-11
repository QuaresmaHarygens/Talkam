# Railway Link Instructions 🔗

## ✅ Railway Project Ready

**Project ID:** `d83eed38-27e4-4539-bd80-431d789d0c97`

## 📋 Steps to Link and Deploy

### Step 1: Wait for Railway CLI Installation

**Railway CLI is currently installing. Wait for it to finish.**

**Check if installed:**
```bash
railway --version
```

**If not installed yet, install:**
```bash
brew install railway
```

### Step 2: Link Project

**Once Railway CLI is installed, run:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
railway link -p d83eed38-27e4-4539-bd80-431d789d0c97
```

**This links your local backend to the Railway project.**

### Step 3: Add PostgreSQL Database

```bash
railway add postgresql
```

**This automatically:**
- Creates PostgreSQL database
- Sets `DATABASE_URL` environment variable

### Step 4: Set Environment Variables

**Generate JWT secret and set variables:**

```bash
# Generate secret
JWT_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')

# Set variables
railway variables set JWT_SECRET="$JWT_SECRET"
railway variables set CORS_ORIGINS="*"
railway variables set ENVIRONMENT="production"
```

**Or set via Railway dashboard:**
- Go to: https://railway.app/dashboard
- Click your project
- Variables tab → Add variables

### Step 5: Deploy

```bash
railway up
```

**Railway will build and deploy your backend.**

### Step 6: Get Your URL

```bash
railway domain
```

**Copy the URL (e.g., `https://talkam-api.railway.app`)**

### Step 7: Run Migrations

```bash
railway run alembic upgrade head
```

### Step 8: Update App

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-RAILWAY-URL.railway.app/v1',
));
```

### Step 9: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

### Step 10: Share APK!

**Now you can share APK with remote users - works from anywhere!**

## 🎯 All Commands in Order

```bash
# 1. Install Railway (if not done)
brew install railway

# 2. Link project
cd "/Users/visionalventure/Watch Liberia/backend"
railway link -p d83eed38-27e4-4539-bd80-431d789d0c97

# 3. Add database
railway add postgresql

# 4. Set variables
railway variables set JWT_SECRET="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
railway variables set CORS_ORIGINS="*"

# 5. Deploy
railway up

# 6. Get URL
railway domain

# 7. Run migrations
railway run alembic upgrade head
```

---

**Run these commands in order to complete deployment!** 🚀



