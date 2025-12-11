# Advanced Troubleshooting - Connection Still Failing 🔧

## 🔍 Deep Diagnosis

If you're still seeing the connection error after firewall fixes, let's check everything systematically.

## Step 1: Verify Current IP Address

**Your IP might have changed:**

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**If IP changed:**
1. Update `mobile/lib/providers.dart` with new IP
2. Rebuild APK
3. Reinstall on device

## Step 2: Test Backend from Computer

```bash
# Test localhost
curl http://127.0.0.1:8000/health

# Test network IP (replace with your current IP)
curl http://10.73.50.47:8000/health
```

**Both should work.** If network IP doesn't work, backend isn't accessible.

## Step 3: Test from Phone Browser

**Critical test - this tells us if it's an app issue or network issue:**

1. Open browser on phone
2. Go to: `http://10.73.50.47:8000/health`
3. Check result:
   - ✅ **Works**: Network is fine, app configuration issue
   - ❌ **Fails**: Network/firewall issue

## Step 4: Check Network Configuration

### Verify Same WiFi Network

**On Phone:**
- Settings → WiFi → Check network name

**On Computer:**
```bash
networksetup -getairportnetwork en0
# Or
ifconfig | grep -A 5 "en0"
```

**Both must be on the same WiFi network!**

### Check Router Settings

Some routers block device-to-device communication:
- Check "AP Isolation" or "Client Isolation" settings
- Disable if enabled
- Some guest networks block inter-device communication

## Step 5: Alternative Solutions

### Solution A: Use ngrok (Bypass Firewall)

**ngrok creates a public tunnel - works even with firewall:**

```bash
# Install ngrok
brew install ngrok

# Start backend (if not running)
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

# In another terminal, create tunnel
ngrok http 8000

# Copy the HTTPS URL (e.g., https://abc123.ngrok.io)
# Update mobile/lib/providers.dart with this URL
# Rebuild APK
```

**Update app:**
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-NGROK-URL.ngrok.io/v1',
));
```

### Solution B: Use Computer's Hostname

**Sometimes hostname works better:**

```bash
# Get hostname
hostname

# Try using: http://YOUR-HOSTNAME.local:8000/v1
```

### Solution C: Use USB Tethering/ADB Port Forwarding

**Forward port through USB:**

```bash
# Connect phone via USB
adb devices

# Forward port
adb reverse tcp:8000 tcp:8000

# Update app to use: http://127.0.0.1:8000/v1
```

**Then update app:**
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'http://127.0.0.1:8000/v1',
));
```

## Step 6: Check App Configuration

**Verify app is using correct IP:**

1. Check `mobile/lib/providers.dart`
2. Ensure it has: `baseUrl: 'http://10.73.50.47:8000/v1'`
3. Rebuild APK if changed
4. Uninstall old app, install new one

## Step 7: Network Debugging

### Check if Port is Accessible

**From computer:**
```bash
# Test if port responds
nc -zv 10.73.50.47 8000

# Or use telnet
telnet 10.73.50.47 8000
```

### Check Firewall Rules

**macOS:**
```bash
# Check firewall status
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# List allowed apps
/usr/libexec/ApplicationFirewall/socketfilterfw --listapps
```

## Step 8: Try Different Port

**Sometimes port 8000 is blocked. Try different port:**

```bash
# Start backend on different port
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080

# Update app to use port 8080
```

## 🎯 Most Likely Issues

1. **IP Address Changed** - WiFi reconnected, got new IP
2. **Different WiFi Networks** - Phone and computer on different networks
3. **Router Blocking** - Router has AP isolation enabled
4. **Firewall Still Blocking** - Firewall rule didn't apply correctly
5. **Old APK Installed** - App still using old IP address

## ✅ Quick Test Checklist

- [ ] Backend running: `ps aux | grep uvicorn`
- [ ] Port listening: `lsof -i :8000`
- [ ] Test localhost: `curl http://127.0.0.1:8000/health`
- [ ] Test network IP: `curl http://10.73.50.47:8000/health`
- [ ] Test from phone browser: `http://10.73.50.47:8000/health`
- [ ] Same WiFi network on both devices
- [ ] IP address hasn't changed
- [ ] App rebuilt with correct IP
- [ ] Old app uninstalled, new one installed

## 🚀 Recommended Next Steps

1. **Test from phone browser first** - This is the critical test
2. **If browser works**: App configuration issue - rebuild APK
3. **If browser fails**: Network/firewall issue - try ngrok or USB forwarding

---

**Start with phone browser test - that tells us everything!** 📱



