# USB Port Forwarding Setup (No Sign Up Needed) 🔌

## ✅ Quick Setup - No Account Required!

This solution uses USB to forward the port - no WiFi, no firewall, no sign-up needed!

## 🚀 Step-by-Step

### Step 1: Connect Phone via USB

1. **Connect Android device to computer via USB**
2. **Enable USB Debugging** on device:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"
3. **Verify connection:**
   ```bash
   adb devices
   # Should show your device
   ```

### Step 2: Forward Port

```bash
adb reverse tcp:8000 tcp:8000
```

**Verify it worked:**
```bash
adb reverse --list
# Should show: tcp:8000 tcp:8000
```

### Step 3: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

**Change to:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/client.dart';

final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'http://127.0.0.1:8000/v1',  // Use localhost via USB forwarding
));
```

### Step 4: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

### Step 5: Install New APK

**Option A: Via ADB**
```bash
adb install "/Users/visionalventure/Watch Liberia/mobile/build/app/outputs/flutter-apk/app-release.apk"
```

**Option B: Transfer Manually**
- Transfer APK to device
- Uninstall old app
- Install new APK

### Step 6: Test!

1. **Open app on device**
2. **Try "Start Anonymous" or login**
3. **Should connect successfully!** ✅

## ✅ Advantages

- ✅ **No sign-up needed**
- ✅ **No WiFi required**
- ✅ **No firewall issues**
- ✅ **Works immediately**
- ✅ **Very reliable**

## ⚠️ Requirements

- Phone connected via USB
- USB debugging enabled
- ADB installed (comes with Android SDK)

## 🔄 Keep USB Forwarding Active

**The forwarding stays active as long as:**
- Phone is connected via USB
- USB debugging is enabled
- You don't disconnect

**To stop:** Disconnect USB or run:
```bash
adb reverse --remove tcp:8000
```

## 🎯 Quick Command Summary

```bash
# 1. Connect phone via USB
adb devices

# 2. Forward port
adb reverse tcp:8000 tcp:8000

# 3. Verify
adb reverse --list

# 4. Update app (use http://127.0.0.1:8000/v1)
# 5. Rebuild APK
# 6. Install and test
```

---

**This is the fastest solution - no sign-up, works immediately!** 🚀



