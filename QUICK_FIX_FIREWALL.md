# Quick Fix: macOS Firewall Blocking Connection 🔥

## ✅ Status Check

- ✅ Backend is running on `0.0.0.0:8000`
- ✅ Port 8000 is listening
- ⚠️ Connection blocked - likely firewall

## 🔧 Quick Fix: Allow Firewall Access

### Option 1: Temporarily Disable Firewall (Testing Only)

```bash
# Disable firewall temporarily
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# Test your app now

# Re-enable after testing
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

### Option 2: Allow Python/uvicorn Through Firewall (Recommended)

**Via System Settings:**
1. **System Settings** → **Network** → **Firewall**
2. Click **Options...**
3. Click **+** to add application
4. Navigate to: `/Users/visionalventure/Watch Liberia/backend/.venv/bin/python3`
5. Set to **Allow incoming connections**
6. Click **OK**

**Or allow uvicorn:**
1. Find uvicorn: `/Users/visionalventure/Watch Liberia/backend/.venv/bin/uvicorn`
2. Add to firewall exceptions
3. Allow incoming connections

### Option 3: Allow Port 8000 (Advanced)

```bash
# Add rule to allow port 8000
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /System/Library/PrivateFrameworks/ApplePushService.framework/apsd
sudo pfctl -f /etc/pf.conf
```

**Or use System Settings:**
- System Settings → Network → Firewall → Options
- Add port 8000 to allowed ports

## 🧪 Test After Fix

**From your phone's browser:**
1. Open browser
2. Go to: `http://10.73.50.47:8000/health`
3. Should see: `{"status":"healthy","service":"talkam-api"}`

**If this works, your app will work too!**

## 📋 Step-by-Step (Easiest Method)

1. **Open System Settings**
2. **Click "Network"**
3. **Click "Firewall"** (on the right)
4. **Click "Options..."** button
5. **Click "+"** to add application
6. **Navigate to:** `/Users/visionalventure/Watch Liberia/backend/.venv/bin/python3`
   - Or press `Cmd+Shift+G` and paste the path
7. **Select "Allow incoming connections"**
8. **Click "OK"**
9. **Test from phone browser:** `http://10.73.50.47:8000/health`

## ⚠️ Security Note

- Temporarily disabling firewall is OK for local testing
- Re-enable after testing
- For production, use proper firewall rules

## ✅ Verification

After fixing firewall:

```bash
# Test from computer
curl http://10.73.50.47:8000/health

# Should return: {"status":"healthy","service":"talkam-api"}
```

**Then test from phone browser - if that works, app will work!**

---

**Most likely fix: Allow Python/uvicorn through macOS Firewall** ✅



