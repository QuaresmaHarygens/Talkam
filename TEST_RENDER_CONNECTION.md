# Test Render Connection 🔍

## 🎯 Quick Test

**Run this command with your Render URL:**
```bash
./scripts/test_render_connection.sh https://your-app.onrender.com
```

**Or test manually:**
```bash
curl https://your-app.onrender.com/v1/health
```

---

## 📋 What Gets Tested

1. **Health Endpoint** (`/v1/health`)
   - Should return: `{"status":"healthy","service":"talkam-api"}`

2. **API Documentation** (`/docs`)
   - Should show FastAPI interactive docs

3. **OpenAPI Schema** (`/openapi.json`)
   - Should return JSON schema

4. **Database Connection** (`/v1/health/db`)
   - Tests if database is connected

5. **Root Endpoint** (`/`)
   - Basic connectivity test

---

## ✅ Expected Results

### Health Endpoint
```bash
curl https://your-app.onrender.com/v1/health
```

**Should return:**
```json
{"status":"healthy","service":"talkam-api"}
```

### API Docs
**Open in browser:**
```
https://your-app.onrender.com/docs
```

**Should show:** FastAPI interactive documentation

---

## 🆘 Troubleshooting

### Service Returns 404

**Possible causes:**
1. **Service still deploying** - Wait a few minutes
2. **Service sleeping** - Free tier services sleep after 15 min inactivity
3. **Wrong URL** - Check Render dashboard for correct URL
4. **Service not started** - Check deployment logs

**Fix:**
- Wait 30-60 seconds for service to wake up
- Check Render dashboard → Events → Logs
- Verify service is deployed successfully

### Service Returns 500 Error

**Possible causes:**
1. **Database not connected** - Check `DATABASE_URL`
2. **Missing environment variables** - Check all vars are set
3. **Application error** - Check logs

**Fix:**
- Verify `DATABASE_URL` is set correctly
- Check all required environment variables
- Review deployment logs for errors

### Service Takes Long to Respond

**Normal for free tier:**
- Services sleep after 15 min inactivity
- First request takes 30-60 seconds to wake up
- Subsequent requests are fast

**Fix:**
- Wait for first request to complete
- Service stays awake for ~15 minutes

---

## 📱 After Successful Test

**Once service is working:**

1. **Update mobile app:**
   ```bash
   ./scripts/update_railway_url.sh https://your-app.onrender.com
   ```

2. **Rebuild APK:**
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

3. **Test APK on device**

---

## 🔗 Useful URLs

**Replace `your-app.onrender.com` with your actual URL:**

- **Health:** `https://your-app.onrender.com/v1/health`
- **API Docs:** `https://your-app.onrender.com/docs`
- **OpenAPI:** `https://your-app.onrender.com/openapi.json`
- **Database Health:** `https://your-app.onrender.com/v1/health/db`

---

**Test your Render deployment now!** 🚀

