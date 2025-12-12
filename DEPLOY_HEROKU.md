# 🚀 Deploy to Heroku - Classic & Reliable

## ⭐ Battle-Tested Platform

**Why Heroku:**
- ✅ **Very reliable** - Battle-tested platform
- ✅ **Well-documented** - Lots of tutorials
- ✅ **Easy PostgreSQL** - One command
- ✅ **Simple deployment** - Git push
- ✅ **Good free tier** - Eco plan $5/month
- ✅ **Auto-scaling** - Handles traffic
- ✅ **Add-ons ecosystem** - Many services

---

## 📋 Step-by-Step Setup

### Step 1: Sign Up for Heroku

1. **Go to:** https://www.heroku.com
2. **Click "Sign up"** (top right)
3. **Create account:**
   - Email address
   - Password
   - Confirm password
4. **Verify email** (check inbox)

**⏱️ Time:** ~2 minutes

**📝 Note:** Free tier removed, but Eco plan is only $5/month

---

### Step 2: Install Heroku CLI

**Install on macOS:**
```bash
brew tap heroku/brew && brew install heroku
```

**Or download:** https://devcenter.heroku.com/articles/heroku-cli

**Verify installation:**
```bash
heroku --version
```

**⏱️ Time:** ~2 minutes

---

### Step 3: Login to Heroku

```bash
heroku login
```

**This will:**
- Open browser for authentication
- Authorize CLI
- You're logged in! ✅

**⏱️ Time:** ~30 seconds

---

### Step 4: Create Heroku App

**Navigate to backend:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
```

**Create app:**
```bash
heroku create talkam-backend
```

**This will:**
- Create app on Heroku
- Add git remote
- Show your app URL: `https://talkam-backend.herokuapp.com`

**⏱️ Time:** ~1 minute

**📝 Note:** If name is taken, try: `talkam-backend-123` or let Heroku generate one

---

### Step 5: Add PostgreSQL Database

**Add PostgreSQL addon:**
```bash
heroku addons:create heroku-postgresql:mini
```

**This will:**
- Create PostgreSQL database
- Auto-set `DATABASE_URL` environment variable ✅
- Show database info

**⏱️ Time:** ~1 minute

**📝 Note:** `mini` plan is free tier, `hobby-dev` is $5/month

---

### Step 6: Set Up Redis (Upstash - Free)

**Open browser:**

1. **Go to:** https://console.upstash.com
2. **Sign up** (free, GitHub easiest)
3. **Create database:**
   - Name: `talkam-redis`
   - Type: Regional
   - Region: Choose closest
4. **Copy Redis URL:**
   - Format: `redis://default:password@host:port`
   - **Save this!**

**⏱️ Time:** ~2 minutes

---

### Step 7: Set Environment Variables

**Set config vars in Heroku:**

```bash
heroku config:set SECRET_KEY="9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4"
```

```bash
heroku config:set REDIS_URL="redis://default:password@host:port"
```
(Replace with your Upstash Redis URL)

```bash
heroku config:set CORS_ORIGINS="*"
```

```bash
heroku config:set ENVIRONMENT="production"
```

**Verify all config vars:**
```bash
heroku config
```

**⏱️ Time:** ~1 minute

**📝 Note:** `DATABASE_URL` is auto-set by Heroku ✅

---

### Step 8: Verify Procfile

**Check if Procfile exists:**
```bash
cat Procfile
```

**Should show:**
```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
release: alembic upgrade head || true
```

**If it doesn't exist or is wrong, create/update it:**
```bash
echo "web: uvicorn app.main:app --host 0.0.0.0 --port \$PORT" > Procfile
echo "release: alembic upgrade head || true" >> Procfile
```

**⏱️ Time:** ~1 minute

---

### Step 9: Deploy to Heroku

**Make sure you're in backend directory:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
```

**Deploy:**
```bash
git push heroku main
```

**This will:**
- Build your app
- Install dependencies
- Run database migrations (release phase)
- Start the server
- Show deployment progress

**Wait for deployment** (~5-10 minutes)

**⏱️ Time:** ~10 minutes (mostly waiting)

---

### Step 10: Test Your Deployment

**Test health endpoint:**
```bash
curl https://talkam-backend.herokuapp.com/health
```

**Expected response:**
```json
{"status":"healthy","service":"talkam-api"}
```

**Or test in browser:**
- Open: `https://talkam-backend.herokuapp.com/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

**View API docs:**
- Open: `https://talkam-backend.herokuapp.com/docs`
- Should see FastAPI Swagger UI

**✅ If you see the health response, deployment is successful!**

---

### Step 11: Update Mobile App

**Update base URL:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/update_railway_url.sh https://talkam-backend.herokuapp.com
```

**Rebuild APK:**
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎉 You're Done!

**Your app is live at:**
`https://talkam-backend.herokuapp.com`

**Total time:** ~20 minutes

---

## 🔑 Quick Reference

**Your Secret Key:**
```
9SPmMcpR0Z7hwgSyOIAzYkxuDaMAJJ7WUocwGGGCvV4
```

**Heroku Commands:**
```bash
# Login
heroku login

# Create app
heroku create app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set config vars
heroku config:set KEY="value"

# View config vars
heroku config

# Deploy
git push heroku main

# View logs
heroku logs --tail

# Open app
heroku open

# Run commands
heroku run command

# Scale dynos
heroku ps:scale web=1
```

---

## 🆘 Troubleshooting

### Build Fails

**Check:**
- `Procfile` exists and is correct
- Dependencies are in `requirements.txt` or `pyproject.toml`
- Python version is specified in `runtime.txt`

**View build logs:**
```bash
heroku logs --tail
```

### App Won't Start

**Check logs:**
```bash
heroku logs --tail
```

**Common issues:**
- Missing environment variables
- Database connection issues
- Port configuration

### Database Connection Fails

**Verify:**
- `DATABASE_URL` is set (auto-set by Heroku)
- Database is running
- Connection string format is correct

**Check database:**
```bash
heroku pg:info
```

### Migration Fails

**Run migrations manually:**
```bash
heroku run alembic upgrade head
```

---

## 📊 Heroku Features

**Eco Plan ($5/month) Includes:**
- ✅ 550-1000 hours/month
- ✅ PostgreSQL database (hobby-dev)
- ✅ Unlimited apps
- ✅ Custom domains
- ✅ SSL certificates
- ✅ Add-ons marketplace
- ✅ Logs and metrics
- ✅ Auto-scaling

**Free Tier:**
- ❌ Removed (as of Nov 2022)
- ✅ Eco plan is affordable alternative

**Add-ons Available:**
- PostgreSQL (included)
- Redis (paid addon or use Upstash)
- Many other services

---

## 📝 Important Files

### Procfile
```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
release: alembic upgrade head || true
```

### runtime.txt (Optional)
```
python-3.9.16
```

### requirements.txt
- Should be generated from `pyproject.toml`
- Or Heroku will auto-detect dependencies

---

## 🎯 Summary

✅ **Very reliable platform**  
✅ **Well-documented**  
✅ **Easy PostgreSQL setup**  
✅ **Simple Git-based deployment**  
✅ **Good add-ons ecosystem**  
✅ **~20 minutes setup**  

**Perfect for production deployment!** 🚀

---

## 📋 Checklist

- [ ] Signed up for Heroku
- [ ] Installed Heroku CLI
- [ ] Logged in to Heroku
- [ ] Created app
- [ ] Added PostgreSQL database
- [ ] Set up Redis (Upstash)
- [ ] Set environment variables:
  - [ ] `SECRET_KEY`
  - [ ] `REDIS_URL`
  - [ ] `CORS_ORIGINS`
  - [ ] `ENVIRONMENT`
  - [ ] `DATABASE_URL` (auto-set)
- [ ] Verified/created Procfile
- [ ] Deployed to Heroku
- [ ] Tested health endpoint
- [ ] Updated mobile app
- [ ] Rebuilt APK

---

## 💰 Pricing

**Eco Plan:** $5/month
- 550-1000 hours/month
- PostgreSQL included
- Good for production

**Free Alternative:**
- Use other platforms (Deta Space, Koyeb, etc.)
- Or use Heroku for production only

---

**Ready to deploy? Start with Step 1: Sign up at https://www.heroku.com** 🚀
