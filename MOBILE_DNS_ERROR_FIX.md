# 🔧 Fix: Mobile App DNS Resolution Error

## ❌ Error: "Failed host lookup: 'little-amity-talkam-c84a1504.koyeb.app'"

**Problem:** The mobile app cannot resolve the Koyeb hostname.

**Error Details:**
```
DioException [connection error]:
Failed host lookup: 'little-amity-talkam-c84a1504.koyeb.app'
SocketException: No address associated with hostname
```

---

## 🔍 Possible Causes

1. **Device has no internet connection**
2. **Koyeb service is sleeping** (free tier auto-sleeps)
3. **DNS resolution issue** on device
4. **URL format issue** in app configuration

---

## ✅ Solutions

### Solution 1: Check Device Internet Connection

**Make sure your device has internet:**
- Check Wi-Fi or mobile data is connected
- Try opening a website in browser
- Verify network connectivity

---

### Solution 2: Wake Up Koyeb Service

**Koyeb free tier services sleep after inactivity.**

**To wake it up:**
1. **Open in browser first:**
   ```
   https://little-amity-talkam-c84a1504.koyeb.app/health
   ```
2. **Wait 10-30 seconds** for service to start
3. **Then try the app again**

**Or trigger from terminal:**
```bash
curl https://little-amity-talkam-c84a1504.koyeb.app/health
```

---

### Solution 3: Verify URL Configuration

**Check the mobile app is using the correct URL:**

**File:** `mobile/lib/providers.dart`

**Should be:**
```dart
baseUrl: 'https://little-amity-talkam-c84a1504.koyeb.app/v1'
```

**Make sure:**
- ✅ URL starts with `https://`
- ✅ No trailing slash after `/v1`
- ✅ Correct domain name

---

### Solution 4: Test DNS Resolution

**On your device, test if DNS works:**
1. Open browser
2. Go to: `https://little-amity-talkam-c84a1504.koyeb.app/health`
3. If it loads, DNS is working
4. If it doesn't, check internet connection

---

### Solution 5: Check Android Network Security

**Android might block cleartext traffic.**

**File:** `mobile/android/app/src/main/AndroidManifest.xml`

**Make sure you have:**
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

**Or create network security config:**
`mobile/android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

**Then in AndroidManifest.xml:**
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

## 🧪 Testing Steps

### Step 1: Test Backend from Computer
```bash
curl https://little-amity-talkam-c84a1504.koyeb.app/health
```

**Expected:** `{"status":"healthy","service":"talkam-api"}`

### Step 2: Test from Device Browser
1. Open browser on device
2. Go to: `https://little-amity-talkam-c84a1504.koyeb.app/health`
3. Should see JSON response

### Step 3: Test App Again
1. Make sure backend is awake (from Step 1)
2. Open app
3. Try login again

---

## 🔧 Quick Fix Checklist

- [ ] Device has internet connection
- [ ] Wake up Koyeb service (curl the health endpoint)
- [ ] Verify URL in `mobile/lib/providers.dart`
- [ ] Test backend in device browser
- [ ] Check Android network security config
- [ ] Rebuild APK if URL was changed

---

## 📋 Most Likely Fix

**The Koyeb service is probably sleeping.**

**Quick fix:**
1. **Wake it up:**
   ```bash
   curl https://little-amity-talkam-c84a1504.koyeb.app/health
   ```
2. **Wait 10-30 seconds**
3. **Try app login again**

**Or:**
1. **Open backend URL in device browser first**
2. **Then try app login**

---

## 🎯 Next Steps

1. **Test backend accessibility** from computer
2. **Wake up Koyeb service** if sleeping
3. **Test from device browser** to verify DNS
4. **Try app login again**

---

**The most common cause is the Koyeb service sleeping. Wake it up first!** 🔧
