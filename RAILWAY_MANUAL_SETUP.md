# Railway Manual Setup Guide 🔧

## ⚠️ Railway CLI Installation

**If Railway CLI installation is having issues, here are alternatives:**

## ✅ Option 1: Install via Script (Recommended)

**Railway provides an install script:**

```bash
curl -fsSL https://railway.app/install.sh | sh
```

**Then add to PATH:**
```bash
export PATH="$HOME/.railway/bin:$PATH"
```

**Or add to `~/.zshrc`:**
```bash
echo 'export PATH="$HOME/.railway/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## ✅ Option 2: Use Railway Dashboard (No CLI Needed)

**You can deploy via Railway dashboard without CLI:**

### Step 1: Go to Railway Dashboard

1. **Open:** https://railway.app/dashboard
2. **Click your project:** `d83eed38-27e4-4539-bd80-431d789d0c97`

### Step 2: Add PostgreSQL

1. **Click "New"** → **"Database"** → **"Add PostgreSQL"**
2. Railway automatically sets `DATABASE_URL`

### Step 3: Set Environment Variables

1. **Go to "Variables" tab**
2. **Add variables:**
   - `JWT_SECRET`: Generate with `python3 -c 'import secrets; print(secrets.token_urlsafe(32))'`
   - `CORS_ORIGINS`: `*`
   - `ENVIRONMENT`: `production`

### Step 4: Deploy via GitHub (Easiest)

1. **Connect GitHub repository:**
   - Click "New" → "GitHub Repo"
   - Select your repository
   - Railway auto-detects and deploys

2. **Or Deploy from local files:**
   - Click "New" → "Empty Service"
   - Upload your backend folder
   - Railway builds and deploys

### Step 5: Get Your URL

1. **After deployment, click on your service**
2. **Go to "Settings" tab**
3. **Generate domain** (or use provided domain)
4. **Copy the URL** (e.g., `https://talkam-api.railway.app`)

### Step 6: Run Migrations

**Use Railway dashboard terminal:**
1. Click on your service
2. Go to "Deployments" tab
3. Click on latest deployment
4. Open "Logs" or "Terminal"
5. Run: `alembic upgrade head`

## ✅ Option 3: Use Railway Web Interface

**Railway has a web-based interface:**

1. **Go to:** https://railway.app/dashboard
2. **Click your project**
3. **Use web interface** to:
   - Add services
   - Set variables
   - Deploy
   - View logs

## 📋 Quick Steps (Dashboard Method)

### Via Railway Dashboard:

1. **Login:** https://railway.app/dashboard
2. **Open project:** `d83eed38-27e4-4539-bd80-431d789d0c97`
3. **Add PostgreSQL:**
   - Click "New" → "Database" → "Add PostgreSQL"
4. **Add Service:**
   - Click "New" → "GitHub Repo" (or "Empty Service")
   - Connect your backend
5. **Set Variables:**
   - Go to service → "Variables" tab
   - Add: `JWT_SECRET`, `CORS_ORIGINS`, `ENVIRONMENT`
6. **Deploy:**
   - Railway auto-deploys from GitHub
   - Or upload files manually
7. **Get URL:**
   - Service → "Settings" → Generate domain
8. **Run Migrations:**
   - Service → "Deployments" → Terminal → `alembic upgrade head`

## 🎯 Recommended: Use Dashboard

**If CLI installation is problematic, use Railway dashboard:**
- ✅ No CLI needed
- ✅ Visual interface
- ✅ Easy to use
- ✅ Same result

## 📱 After Deployment

**Once you have Railway URL:**

1. **Update app:** `mobile/lib/providers.dart` with Railway URL
2. **Rebuild APK:** `flutter build apk --release`
3. **Share APK** - works for remote users!

---

**Use Railway dashboard if CLI installation is having issues!** 🚀



