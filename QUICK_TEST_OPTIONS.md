# Quick Testing Options - Deploy & Test Remotely ⚡

## 🎯 Fastest Options (Choose One)

---

## Option 1: LocalTunnel (2 Minutes - No Sign-up) ⚡

**Best for:** Quick testing right now

### Setup:

```bash
# Install LocalTunnel
npm install -g localtunnel

# Start your backend (if not running)
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000

# In another terminal, create tunnel
lt --port 8000
```

**You'll get a URL like:** `https://random-name.loca.lt`

**Update mobile app:**
```bash
./scripts/update_railway_url.sh https://random-name.loca.lt
cd mobile && flutter build apk --release
```

**Or use the script:**
```bash
./scripts/quick_test_localtunnel.sh
```

**Pros:**
- ✅ No sign-up needed
- ✅ Works immediately
- ✅ Free

**Cons:**
- ⚠️ URL changes each time
- ⚠️ Not for production

---

## Option 2: Render (10 Minutes - Free Tier) ⭐

**Best for:** Stable testing and production

### Quick Setup:

1. **Go to:** https://render.com
2. **Sign up** (free)
3. **New → Web Service**
4. **Connect GitHub** → Select repo
5. **Settings:**
   - Root Directory: `backend`
   - Build: `pip install -e .`
   - Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. **Add PostgreSQL** (New → PostgreSQL)
7. **Set Variables:**
   - `JWT_SECRET` (generate token)
   - `CORS_ORIGINS=*`
   - `ENVIRONMENT=production`
8. **Deploy** - Auto-deploys!
9. **Get URL** - `https://your-app.onrender.com`

**Full guide:** `QUICK_DEPLOY_RENDER.md`

**Pros:**
- ✅ Free tier
- ✅ Stable URL
- ✅ Auto-deploys
- ✅ PostgreSQL included

**Cons:**
- ⚠️ Services sleep after 15 min (free tier)

---

## Option 3: ngrok (5 Minutes - Free Account) 🔒

**Best for:** Professional testing with stable URLs

### Setup:

1. **Sign up:** https://ngrok.com (free)
2. **Install:**
   ```bash
   brew install ngrok/ngrok/ngrok
   ```
3. **Get auth token** from ngrok dashboard
4. **Authenticate:**
   ```bash
   ngrok config add-authtoken YOUR_TOKEN
   ```
5. **Start backend:**
   ```bash
   cd backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
6. **Create tunnel:**
   ```bash
   ngrok http 8000
   ```
7. **Get URL:** `https://abc123.ngrok.io`

**Update mobile app:**
```bash
./scripts/update_railway_url.sh https://abc123.ngrok.io
cd mobile && flutter build apk --release
```

**Pros:**
- ✅ Stable URLs (with account)
- ✅ Professional
- ✅ Free tier

**Cons:**
- ⚠️ Requires sign-up
- ⚠️ URL changes (free tier)

---

## Option 4: Fly.io (15 Minutes - Free Tier) 🌍

**Best for:** Global deployment

### Quick Setup:

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Initialize
cd backend
fly launch

# Add PostgreSQL
fly postgres create
fly postgres attach <db-name>

# Set secrets
fly secrets set JWT_SECRET="your-secret"
fly secrets set CORS_ORIGINS="*"
fly secrets set ENVIRONMENT="production"

# Deploy
fly deploy
```

**Pros:**
- ✅ Free tier
- ✅ Global network
- ✅ Fast

**Cons:**
- ⚠️ Requires CLI
- ⚠️ More setup

---

## 🎯 Recommendation

**For immediate testing:**
→ **LocalTunnel** (2 minutes, no sign-up)

**For stable testing:**
→ **Render** (10 minutes, free tier)

**For professional testing:**
→ **ngrok** (5 minutes, free account)

---

## 📋 Quick Comparison

| Option | Time | Sign-up | URL Stability | Best For |
|--------|------|---------|---------------|----------|
| **LocalTunnel** | 2 min | ❌ No | Changes | Quick test |
| **Render** | 10 min | ✅ Yes | Stable | Production |
| **ngrok** | 5 min | ✅ Yes | Stable* | Professional |
| **Fly.io** | 15 min | ✅ Yes | Stable | Global |

*Stable with paid plan

---

## 🚀 Start Now

**Fastest way to test:**

```bash
# Option 1: LocalTunnel (instant)
npm install -g localtunnel
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 &
lt --port 8000
# Copy the URL and update mobile app

# Option 2: Render (stable)
# Go to https://render.com and follow QUICK_DEPLOY_RENDER.md
```

---

**Choose the option that fits your needs!** 🎯

