# Android Testing Guide - Complete Setup

## 🎯 Quick Start

This guide will help you test the Talkam Liberia mobile app on Android, including all the new features we just implemented.

## Prerequisites

### 1. Install Flutter

```bash
# Check if Flutter is installed
flutter --version

# If not installed, install it:
# macOS
brew install --cask flutter

# Or download from: https://flutter.dev/docs/get-started/install
```

### 2. Install Android Studio

1. Download from: https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio → More Actions → SDK Manager
4. Install:
   - Android SDK Platform (latest)
   - Android SDK Build-Tools
   - Android Emulator

### 3. Set Up Android Emulator

```bash
# List available emulators
flutter emulators

# Create a new emulator (if none exist)
# Open Android Studio → Device Manager → Create Device
# Choose: Pixel 5 or similar
# System Image: Latest Android (API 33+)
```

## Step-by-Step Setup

### Step 1: Verify Flutter Setup

```bash
# Check Flutter installation
flutter doctor

# Should show:
# ✅ Flutter (Channel stable)
# ✅ Android toolchain
# ✅ Android Studio
# ✅ Connected device (or emulator)
```

**Fix any issues** shown by `flutter doctor` before proceeding.

### Step 2: Start Backend Server

**Terminal 1 - Backend:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"

# Make sure backend is running
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Verify backend is running:**
```bash
curl http://127.0.0.1:8000/health
# Should return: {"status":"healthy","service":"talkam-api"}
```

### Step 3: Configure Mobile App API Endpoint

The mobile app is already configured to use:
- **Android Emulator**: `http://10.0.2.2:8000/v1` (automatically detected)
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000/v1`

**For Physical Android Device:**

1. Find your computer's IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Or
   ipconfig getifaddr en0  # macOS
   ```

2. Update `mobile/lib/api/client.dart` if needed:
   ```dart
   // For physical device, you can override:
   TalkamApiClient(baseUrl: 'http://192.168.1.XXX:8000/v1')
   ```

### Step 4: Install Mobile App Dependencies

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter pub get
```

### Step 5: Start Android Emulator

**Option A: Using Flutter**
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Or launch default
flutter emulators --launch Pixel_5_API_33
```

**Option B: Using Android Studio**
1. Open Android Studio
2. Tools → Device Manager
3. Click ▶️ Play button on an emulator

**Option C: Using Command Line**
```bash
# List AVDs
emulator -list-avds

# Launch
emulator -avd <avd-name>
```

### Step 6: Verify Device Connection

```bash
# Check connected devices
flutter devices

# Should show something like:
# sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 13 (API 33)
```

### Step 7: Run the App

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"

# Run on connected device/emulator
flutter run

# Or run on specific device
flutter run -d <device-id>
```

**The app should:**
1. Build and install on emulator/device
2. Launch automatically
3. Show the welcome/login screen

## Testing New Features

### 1. Test Device Token Registration

The app should automatically register device tokens when:
- User logs in
- User starts anonymous session
- App launches with valid token

**To verify:**
1. Login or start anonymous session
2. Check backend logs for device token registration
3. Or check database:
   ```sql
   SELECT * FROM device_tokens;
   ```

### 2. Test Push Notifications

**Note**: Push notifications require FCM/APNs configuration. For now, they work in stub mode.

**To test:**
1. Create a report
2. Check if other users receive notifications
3. Verify in app's Notifications screen

### 3. Test Advanced Search

1. Navigate to Reports feed
2. Use search/filter features
3. Test different filter combinations

### 4. Test Attestation

1. Create a report (as User A)
2. Login as User B (in same county)
3. Check Notifications tab
4. View report and attest to it

## Troubleshooting

### Issue: "No devices found"

**Solution:**
```bash
# Check devices
flutter devices

# If no devices, start emulator
flutter emulators --launch <emulator-id>

# Or connect physical device via USB
# Enable USB debugging on device
```

### Issue: "Connection refused" or API errors

**For Android Emulator:**
- ✅ Use `10.0.2.2:8000` (already configured)
- ✅ Backend must be running on `0.0.0.0:8000` (not just `127.0.0.1`)

**For Physical Device:**
- ✅ Use your computer's IP address (not `127.0.0.1`)
- ✅ Ensure phone and computer are on same WiFi network
- ✅ Check firewall isn't blocking port 8000

**Fix backend binding:**
```bash
# Make sure backend runs on 0.0.0.0 (not just 127.0.0.1)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Issue: Build errors

**Solution:**
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### Issue: Gradle build fails

**Solution:**
```bash
cd mobile/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "SDK location not found"

**Solution:**
```bash
# Set Android SDK path
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Or add to ~/.zshrc or ~/.bash_profile
```

## Testing Checklist

### Basic Functionality
- [ ] App launches successfully
- [ ] Can login/register
- [ ] Can create anonymous session
- [ ] Can view reports feed
- [ ] Can create a report
- [ ] Location services work

### New Features
- [ ] Device token registered (check backend logs)
- [ ] Notifications screen works
- [ ] Can attest to reports
- [ ] Advanced search works
- [ ] Map view displays reports

### API Integration
- [ ] API calls succeed
- [ ] Authentication works
- [ ] Offline queue works
- [ ] Sync service works

## Quick Test Commands

### Check Backend is Running
```bash
curl http://127.0.0.1:8000/health
```

### Check Emulator Connection
```bash
adb devices
# Should show: emulator-5554    device
```

### View App Logs
```bash
# While app is running
flutter logs

# Or use Android Studio Logcat
```

### Test API from Emulator
```bash
# From emulator shell
adb shell
curl http://10.0.2.2:8000/health
```

## Development Workflow

### Hot Reload
While app is running:
- Press `r` in terminal → Hot reload
- Press `R` in terminal → Hot restart
- Press `q` in terminal → Quit

### Debugging
1. **VS Code**: Install Flutter extension, set breakpoints
2. **Android Studio**: Full debugging support
3. **Chrome DevTools**: For web debugging

### Viewing Logs
```bash
# Flutter logs
flutter logs

# Android logs
adb logcat | grep flutter

# Backend logs
# Check terminal where uvicorn is running
```

## Testing Specific Features

### Test Device Token Registration

1. **Start app and login**
2. **Check backend logs** for:
   ```
   POST /v1/device-tokens/register
   ```

3. **Or query database:**
   ```sql
   SELECT * FROM device_tokens WHERE platform = 'android';
   ```

### Test Push Notifications

**Note**: Requires FCM setup. For now, works in stub mode.

1. Create a report
2. Check if notifications are created in database
3. View in app's Notifications screen

### Test Attestation Flow

1. **User A**: Create a report
2. **User B**: Login (same county)
3. **User B**: Check Notifications tab
4. **User B**: View report → Attest button
5. **User B**: Submit attestation
6. **Verify**: Report witness count increases

## Production Build

### Build APK for Testing
```bash
cd mobile
flutter build apk --debug
# APK will be in: build/app/outputs/flutter-apk/app-debug.apk
```

### Install APK on Device
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or transfer file and install manually
```

## Next Steps

1. ✅ Set up Flutter and Android Studio
2. ✅ Start backend server
3. ✅ Launch Android emulator
4. ✅ Run the app
5. ✅ Test all features
6. ⚙️ Configure FCM for push notifications (optional)
7. ⚙️ Build release APK for distribution

---

**Ready to test on Android!** 📱
