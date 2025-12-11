# Fix "Operation not permitted" Connection Error 🔧

## ⚠️ Current Error

**Error:** `SocketException: Connection failed (OS Error: Operation not permitted, errno = 1)`  
**Address:** `10.73.50.47:8000`

This error means the connection is being **blocked** - likely by firewall or backend not accessible.

## ✅ Solutions

### Solution 1: Check Backend is Running

**Start backend on network-accessible address:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Important:** Must use `--host 0.0.0.0` (not `127.0.0.1`) to allow network access.

### Solution 2: Check macOS Firewall

**macOS may be blocking incoming connections:**

1. **System Settings → Network → Firewall**
2. **Options** → Check "Block all incoming connections"
3. **If enabled, either:**
   - Disable temporarily for testing
   - Or add Python/uvicorn to allowed apps

**Or via Terminal:**
```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Temporarily disable (for testing only)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# Re-enable after testing
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

### Solution 3: Verify Network Connection

**Test from your phone's browser:**

1. Open browser on phone
2. Go to: `http://10.73.50.47:8000/health`
3. Should see: `{"status":"healthy","service":"talkam-api"}`

**If this doesn't work:**
- Phone and computer not on same WiFi
- Firewall blocking connection
- Backend not running

### Solution 4: Check IP Address

**Your IP might have changed:**

```bash
# Get current IP
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
```

**If IP changed:**
1. Update `mobile/lib/providers.dart` with new IP
2. Rebuild APK: `cd mobile && flutter build apk --release`
3. Reinstall on device

### Solution 5: Test Backend Locally First

**Verify backend works locally:**

```bash
# Test from computer
curl http://127.0.0.1:8000/health

# Test from network IP
curl http://10.73.50.47:8000/health
```

**Both should return:** `{"status":"healthy","service":"talkam-api"}`

## 🔍 Step-by-Step Troubleshooting

### Step 1: Verify Backend is Running

```bash
# Check if backend process is running
ps aux | grep uvicorn | grep -v grep

# If not running, start it:
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Step 2: Test from Computer

```bash
# Test localhost
curl http://127.0.0.1:8000/health

# Test network IP
curl http://10.73.50.47:8000/health
```

**Both should work.** If network IP doesn't work, backend isn't listening on `0.0.0.0`.

### Step 3: Test from Phone Browser

1. Open browser on phone
2. Navigate to: `http://10.73.50.47:8000/health`
3. Should see JSON response

**If this fails:**
- Firewall is blocking
- Different WiFi networks
- IP address changed

### Step 4: Check Firewall

**macOS Firewall Settings:**
- System Settings → Network → Firewall
- Temporarily disable for testing
- Or add Python to allowed apps

### Step 5: Verify Same Network

**Both devices must be on same WiFi:**
- Check WiFi name on phone
- Check WiFi name on computer
- Must match exactly

## 🎯 Quick Fix Checklist

- [ ] Backend running with `--host 0.0.0.0`
- [ ] Test from computer: `curl http://10.73.50.47:8000/health` works
- [ ] Test from phone browser: `http://10.73.50.47:8000/health` works
- [ ] Phone and computer on same WiFi network
- [ ] Firewall allows incoming connections on port 8000
- [ ] IP address hasn't changed

## 🚀 Most Likely Fix

**The backend is probably not running or not accessible from network.**

**Start backend:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Then test from phone browser:**
- Go to: `http://10.73.50.47:8000/health`
- If this works, the app will work too!

## 📋 Alternative: Use ngrok (Temporary Testing)

If firewall is too complex, use ngrok for temporary testing:

```bash
# Install ngrok
brew install ngrok

# Start backend
cd backend && uvicorn app.main:app --reload

# In another terminal, create tunnel
ngrok http 8000

# Use the ngrok URL in app (e.g., https://abc123.ngrok.io)
```

**Update app with ngrok URL temporarily for testing.**

---

**Most common issue: Backend not running or firewall blocking. Check these first!** ✅



