# Fix USB Forwarding Not Working 🔧

## ⚠️ Issue

USB forwarding is set up but not working - phone browser can't access `http://127.0.0.1:8000/health`

## ✅ Solutions to Try

### Solution 1: Re-establish USB Forwarding

**Remove and re-add forwarding:**

```bash
# Remove all forwardings
adb reverse --remove-all

# Add forwarding again
adb reverse tcp:8000 tcp:8000

# Verify
adb reverse --list
```

**Then test from phone browser again.**

### Solution 2: Check Backend is Running on Correct Host

**Backend must run on `127.0.0.1` (not `0.0.0.0`) for USB forwarding:**

```bash
# Check current backend
ps aux | grep uvicorn | grep -v grep

# If running on 0.0.0.0, restart on 127.0.0.1:
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### Solution 3: Try Different Port

**Sometimes port 8000 has issues. Try port 8080:**

```bash
# Forward different port
adb reverse tcp:8080 tcp:8000

# Update app to use port 8080
# Edit mobile/lib/providers.dart:
# baseUrl: 'http://127.0.0.1:8080/v1'
```

### Solution 4: Use Network IP Instead

**If USB forwarding doesn't work, use WiFi with your computer's IP:**

**Get your IP:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
```

**Update app:**
```dart
// Edit mobile/lib/providers.dart
baseUrl: 'http://YOUR_IP:8000/v1',  // e.g., http://10.122.117.47:8000/v1
```

**Then:**
- Ensure phone and computer on same WiFi
- Ensure backend runs on `0.0.0.0:8000`
- Rebuild APK

### Solution 5: Use ngrok (Most Reliable)

**If USB forwarding continues to fail, use ngrok:**

1. **Sign up for free ngrok account:** https://dashboard.ngrok.com/signup
2. **Get authtoken:** https://dashboard.ngrok.com/get-started/your-authtoken
3. **Configure:**
   ```bash
   ngrok config add-authtoken YOUR_TOKEN
   ```
4. **Start tunnel:**
   ```bash
   ngrok http 8000
   ```
5. **Use HTTPS URL in app** (e.g., `https://abc123.ngrok-free.app/v1`)

## 🔍 Diagnostic Steps

### Step 1: Verify Device Connection

```bash
adb devices
# Should show your device
```

### Step 2: Check Forwarding

```bash
adb reverse --list
# Should show: tcp:8000 tcp:8000
```

### Step 3: Test Backend Locally

```bash
curl http://127.0.0.1:8000/health
# Should return: {"status":"healthy","service":"talkam-api"}
```

### Step 4: Check Backend Host

```bash
ps aux | grep uvicorn | grep -v grep
# Should show --host 127.0.0.1 (not 0.0.0.0)
```

## 🎯 Recommended: Switch to Network IP

**Since USB forwarding isn't working, let's use WiFi with your computer's IP:**

### Quick Setup:

1. **Get your IP:**
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
   ```

2. **Update app configuration:**
   - Edit `mobile/lib/providers.dart`
   - Use your computer's IP instead of `127.0.0.1`

3. **Ensure backend runs on network:**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. **Rebuild APK**

5. **Ensure phone and computer on same WiFi**

## ✅ Quick Fix Commands

```bash
# 1. Remove and re-add forwarding
adb reverse --remove-all
adb reverse tcp:8000 tcp:8000

# 2. Verify
adb reverse --list

# 3. Check backend host
ps aux | grep uvicorn | grep host

# 4. Restart backend on 127.0.0.1 if needed
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

---

**Try re-establishing forwarding first, then switch to network IP if it still doesn't work!** 🔧



