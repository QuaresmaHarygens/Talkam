# Fix Android Device Connection Error 🔧

## ⚠️ Problem

**Error:** `Connection failed (OS Error: Operation not permitted, errno = 1)`  
**Address:** `10.0.2.2:8000`

This happens because:
- `10.0.2.2` only works on **Android Emulator**
- On **Physical Android Device**, you need your **computer's IP address**

## ✅ Solution

### Step 1: Find Your Computer's IP Address

**On macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**On Windows:**
```bash
ipconfig
```

Look for your local network IP (usually starts with `192.168.` or `10.`)

**Your current IP:** `10.73.50.47` ✅

### Step 2: Update Mobile App Configuration

**Option A: Quick Fix (Edit Code)**

1. Open: `mobile/lib/providers.dart`
2. Update the `baseUrl`:
   ```dart
   final apiClientProvider = Provider((ref) => TalkamApiClient(
     baseUrl: 'http://10.73.50.47:8000/v1',  // Your computer's IP
   ));
   ```
3. Rebuild APK:
   ```bash
   cd mobile
   flutter build apk --release
   ```

**Option B: Use Environment Variable (Better)**

1. Create `mobile/lib/config.dart`:
   ```dart
   class AppConfig {
     // Change this to your computer's IP when testing on physical device
     static const String apiBaseUrl = 'http://10.73.50.47:8000/v1';
     // For emulator: 'http://10.0.2.2:8000/v1'
   }
   ```

2. Update `mobile/lib/providers.dart`:
   ```dart
   import 'config.dart';
   
   final apiClientProvider = Provider((ref) => TalkamApiClient(
     baseUrl: AppConfig.apiBaseUrl,
   ));
   ```

### Step 3: Ensure Backend is Running

**Backend must be accessible from your network:**

```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Important:** Use `--host 0.0.0.0` (not just `127.0.0.1`) so it's accessible from network.

### Step 4: Verify Connection

**From your computer:**
```bash
curl http://10.73.50.47:8000/health
# Should return: {"status":"healthy","service":"talkam-api"}
```

**From your phone's browser:**
- Open browser on phone
- Go to: `http://10.73.50.47:8000/health`
- Should see: `{"status":"healthy","service":"talkam-api"}`

### Step 5: Rebuild and Install APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

**Install on device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Or transfer APK to device and install manually.

## 🔍 Troubleshooting

### Still Getting Connection Error?

1. **Check Firewall**
   - macOS: System Settings → Firewall → Allow incoming connections
   - Or temporarily disable firewall for testing

2. **Check Network**
   - Phone and computer must be on **same WiFi network**
   - Not on different networks (e.g., phone on mobile data)

3. **Check Backend**
   ```bash
   # Verify backend is running
   curl http://127.0.0.1:8000/health
   
   # Verify accessible from network
   curl http://10.73.50.47:8000/health
   ```

4. **Check IP Address**
   - IP might change if you reconnect to WiFi
   - Re-run `ifconfig` to get current IP
   - Update `providers.dart` with new IP

### "Operation not permitted" Error

This usually means:
- Firewall blocking connection
- Backend not running on `0.0.0.0`
- Phone and computer on different networks

## 📋 Quick Checklist

- [ ] Backend running on `0.0.0.0:8000` (not just `127.0.0.1`)
- [ ] Phone and computer on same WiFi network
- [ ] Updated `providers.dart` with computer's IP address
- [ ] Rebuilt APK with new configuration
- [ ] Installed new APK on device
- [ ] Firewall allows incoming connections

## 🎯 Current Configuration

**Your Computer IP:** `10.73.50.47`  
**Backend Port:** `8000`  
**API URL:** `http://10.73.50.47:8000/v1`

**Update this in:** `mobile/lib/providers.dart`

---

**After updating, rebuild APK and the connection should work!** ✅

