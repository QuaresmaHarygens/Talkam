# How to Get Your Railway URL 🔗

## 🎯 Quick Steps

### Step 1: Open Your Service in Railway

1. **Go to:** https://railway.app/dashboard
2. **Click on your project** (if you have multiple projects)
3. **Click on your backend service** (the one you deployed)

### Step 2: Go to Settings

1. **Click on the "Settings" tab** (usually at the top of the service page)
2. **Scroll down** to find the "Domains" section

### Step 3: Generate Domain

1. **In the "Domains" section**, you'll see:
   - A list of existing domains (if any)
   - A button that says **"Generate Domain"** or **"New Domain"**

2. **Click "Generate Domain"**

3. **Railway will create a URL** like:
   - `https://talkam-api.railway.app`
   - `https://talkam-api-production.up.railway.app`
   - Or similar format

### Step 4: Copy the URL

1. **The URL will appear** in the domains list
2. **Click on the URL** or **copy it** from the list
3. **Save it somewhere** - you'll need it!

## 📋 Visual Guide

```
Railway Dashboard
  └── Your Project
      └── Your Backend Service
          └── Settings Tab
              └── Domains Section
                  └── [Generate Domain Button]
                      └── Your URL appears here!
```

## 🔍 Alternative: Find URL in Service Overview

**Sometimes the URL is visible in the service overview:**

1. **Go to your service** (main page, not settings)
2. **Look for a "Domains" or "URL" section** in the service card
3. **The URL might be displayed there** already

## ✅ What Your URL Looks Like

**Railway URLs typically look like:**
- `https://your-service-name.railway.app`
- `https://your-service-name-production.up.railway.app`
- `https://random-words.up.railway.app`

**Example:**
```
https://talkam-api.railway.app
```

## 🎯 After You Get the URL

**Once you have your Railway URL:**

1. **Test it:**
   ```bash
   curl https://YOUR-URL.railway.app/health
   ```
   Should return: `{"status":"healthy","service":"talkam-api"}`

2. **Or use the verification script:**
   ```bash
   ./scripts/verify_railway_deployment.sh https://YOUR-URL.railway.app
   ```

3. **Update your mobile app:**
   ```bash
   ./scripts/update_railway_url.sh https://YOUR-URL.railway.app
   ```

4. **Rebuild APK:**
   ```bash
   cd mobile && flutter build apk --release
   ```

## 🆘 Troubleshooting

### Can't Find "Generate Domain" Button?

**Possible reasons:**
1. **Service not deployed yet** - Deploy first, then generate domain
2. **Looking in wrong place** - Make sure you're in Settings → Domains
3. **Service is paused** - Check if service is running

### URL Not Working?

**Check:**
1. **Service is deployed** - Go to Deployments tab, verify latest deployment succeeded
2. **Service is running** - Check service status (should be "Active")
3. **Health endpoint** - Test `/health` endpoint in browser

### Need Custom Domain?

**Railway also supports custom domains:**
1. **In Domains section**, click "Custom Domain"
2. **Add your domain** (e.g., `api.yourdomain.com`)
3. **Follow DNS setup instructions**

## 📝 Quick Checklist

- [ ] Opened Railway dashboard
- [ ] Clicked on backend service
- [ ] Went to Settings tab
- [ ] Found Domains section
- [ ] Clicked "Generate Domain"
- [ ] Copied the URL
- [ ] Tested the URL (health endpoint)
- [ ] Updated mobile app with URL

---

## 🚀 Next Steps

**After you get your Railway URL:**

1. **Share the URL with me** and I'll help update the app
2. **Or run the update script yourself:**
   ```bash
   ./scripts/update_railway_url.sh https://YOUR-URL.railway.app
   ```

**Your Railway URL:** _________________________

---

**Follow these steps to get your Railway URL!** 🔗

