# Render 502 Error - Troubleshooting 🔧

## ⚠️ Current Status

**Service URL:** `https://talkam-xmx1.onrender.com`
**Error:** 502 Bad Gateway

## 🔍 What 502 Means

**502 Bad Gateway** usually means:
1. **Service is sleeping** (free tier - normal)
2. **Service is starting up** (takes 30-60 seconds)
3. **Deployment issue** (check logs)

## ✅ Solutions

### Solution 1: Wait for Service to Wake Up (Most Common)

**Free tier services sleep after 15 minutes of inactivity.**

**What to do:**
1. **Make a request** to your service
2. **Wait 30-60 seconds** for it to wake up
3. **Try again** - should work after wake-up

**Test:**
```bash
curl https://talkam-xmx1.onrender.com/v1/health
# Wait 30-60 seconds, then try again
```

### Solution 2: Check Deployment Status

1. **Go to Render Dashboard:** https://dashboard.render.com
2. **Click on your service** (`talkam-xmx1`)
3. **Check "Events" tab:**
   - Is deployment successful?
   - Any errors?

4. **Check "Logs" tab:**
   - Look for errors
   - Check if service started correctly

### Solution 3: Verify Environment Variables

1. **Service → "Environment" tab**
2. **Check these are set:**
   - ✅ `DATABASE_URL`
   - ✅ `JWT_SECRET`
   - ✅ `CORS_ORIGINS`
   - ✅ `ENVIRONMENT`

### Solution 4: Check Service Settings

1. **Service → "Settings" tab**
2. **Verify:**
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Root Directory:** `backend` (or empty if repo root is backend)

### Solution 5: Redeploy Service

**If service won't start:**
1. **Go to service in Render**
2. **Click "Manual Deploy"** → **"Deploy latest commit"**
3. **Watch deployment logs**
4. **Wait for completion**

## 🧪 Test After Fix

**Once service is awake/running:**

```bash
# Test health endpoint
curl https://talkam-xmx1.onrender.com/v1/health

# Should return:
# {"status":"healthy","service":"talkam-api"}
```

**Test in browser:**
- Open: `https://talkam-xmx1.onrender.com/docs`
- Should show FastAPI documentation

## 📝 Free Tier Behavior

**Render Free Tier:**
- Services sleep after 15 minutes of inactivity
- First request takes 30-60 seconds to wake up
- Subsequent requests are fast (while awake)
- This is normal behavior

**To avoid sleeping:**
- Upgrade to paid plan (always-on)
- Or use a service like UptimeRobot to ping your service every 10 minutes

## ✅ Next Steps

1. **Wait 30-60 seconds** and test again
2. **Check Render dashboard** for deployment status
3. **Review logs** for any errors
4. **Once working**, update mobile app:
   ```bash
   ./scripts/update_railway_url.sh https://talkam-xmx1.onrender.com
   ```

---

**502 is usually just the service sleeping - wait a minute and try again!** ⏰

