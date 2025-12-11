# Fix USB Forwarding Connection Error 🔧

## ⚠️ Current Error

**Error:** `Connection failed (OS Error: Operation not permitted, errno = 1)`  
**Address:** `127.0.0.1:8000`

The app is trying to connect via USB forwarding, but the connection is failing.

## ✅ Solution Steps

### Step 1: Connect Phone via USB

1. **Connect Android device to computer via USB cable**
2. **On phone:** Allow USB debugging when prompted
3. **Verify connection:**
   ```bash
   adb devices
   # Should show your device (not empty)
   ```

**If no device shows:**
- Check USB cable is connected
- Enable USB debugging on phone
- Try different USB port
- Check phone shows "USB debugging connected"

### Step 2: Forward Port

**Run this command:**
```bash
adb reverse tcp:8000 tcp:8000
```

**Verify it worked:**
```bash
adb reverse --list
# Should show: tcp:8000 tcp:8000
```

### Step 3: Verify Backend is Running

**Check backend is running on localhost:**
```bash
curl http://127.0.0.1:8000/health
# Should return: {"status":"healthy","service":"talkam-api"}
```

**If not running, start it:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### Step 4: Test Connection from Phone

**After forwarding, test from phone:**
1. Open browser on phone
2. Go to: `http://127.0.0.1:8000/health`
3. Should see: `{"status":"healthy","service":"talkam-api"}`

**If browser works, app will work too!**

## 🔍 Troubleshooting

### "adb: command not found"

**Install Android SDK Platform Tools:**
```bash
# macOS
brew install android-platform-tools

# Or download from: https://developer.android.com/studio/releases/platform-tools
```

### "no devices/emulators found"

**Check:**
1. USB cable is connected
2. USB debugging enabled on phone
3. Phone shows "USB debugging connected" notification
4. Try different USB port/cable

**Enable USB Debugging:**
1. Settings → About Phone
2. Tap "Build Number" 7 times
3. Settings → Developer Options
4. Enable "USB Debugging"

### "Operation not permitted" Error

**This usually means:**
1. **Port not forwarded** → Run `adb reverse tcp:8000 tcp:8000`
2. **Backend not running** → Start backend on port 8000
3. **Phone not connected** → Check `adb devices`

### Port Forwarding Not Working

**Try these:**
```bash
# Remove existing forwarding
adb reverse --remove tcp:8000

# Add forwarding again
adb reverse tcp:8000 tcp:8000

# Verify
adb reverse --list
```

### Backend Not Accessible

**Check backend is running:**
```bash
# Check process
ps aux | grep uvicorn | grep -v grep

# Check port
lsof -i :8000

# Test locally
curl http://127.0.0.1:8000/health
```

## ✅ Quick Fix Checklist

- [ ] Phone connected via USB
- [ ] USB debugging enabled
- [ ] `adb devices` shows your device
- [ ] Port forwarded: `adb reverse tcp:8000 tcp:8000`
- [ ] Backend running on port 8000
- [ ] Test from phone browser: `http://127.0.0.1:8000/health` works
- [ ] App installed with USB forwarding configuration

## 🚀 Quick Commands

```bash
# 1. Check device
adb devices

# 2. Forward port
adb reverse tcp:8000 tcp:8000

# 3. Verify forwarding
adb reverse --list

# 4. Test backend
curl http://127.0.0.1:8000/health

# 5. Check backend process
ps aux | grep uvicorn | grep -v grep
```

## 📋 Step-by-Step Fix

**Run these commands in order:**

```bash
# 1. Connect phone via USB, then:
adb devices

# 2. Forward port
adb reverse tcp:8000 tcp:8000

# 3. Verify
adb reverse --list

# 4. Check backend
curl http://127.0.0.1:8000/health

# 5. If backend not running, start it:
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

**After these steps, test the app again!**

---

**Most likely issue: Port not forwarded or phone not connected. Run `adb reverse tcp:8000 tcp:8000`!** ✅



