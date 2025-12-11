# Quick Start - Android Testing 🚀

## Prerequisites Check

```bash
# 1. Check Flutter
flutter --version
# Should show: Flutter 3.x.x

# 2. Check Android setup
flutter doctor
# Should show Android toolchain as ✅

# 3. Check devices
flutter devices
# Should show at least one Android device/emulator
```

## Quick Setup (5 Minutes)

### Step 1: Start Backend (Terminal 1)

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Verify:** Open http://127.0.0.1:8000/health in browser

### Step 2: Start Android Emulator

```bash
# Option A: List and launch
flutter emulators
flutter emulators --launch <emulator-id>

# Option B: Use Android Studio
# Open Android Studio → Device Manager → Click Play ▶️
```

**Wait for emulator to fully boot** (home screen visible)

### Step 3: Install Dependencies

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter pub get
```

### Step 4: Run the App

```bash
flutter run
```

**The app will:**
1. Build (first time takes 2-3 minutes)
2. Install on emulator
3. Launch automatically

## Testing Features

### Test 1: Login/Anonymous Session

1. **Open app** → Should show welcome/login screen
2. **Click "Start Anonymous"** or login
3. **Verify**: App loads home screen

### Test 2: Device Token Registration

1. **After login**, check backend terminal
2. **Look for**: `POST /v1/device-tokens/register`
3. **Or check database**:
   ```sql
   SELECT * FROM device_tokens WHERE platform = 'android';
   ```

### Test 3: Create Report

1. **Tap "Create Report"** button
2. **Fill in details**:
   - Category: Infrastructure
   - Severity: High
   - Summary: Test report
3. **Allow location** permission
4. **Submit report**
5. **Verify**: Report appears in feed

### Test 4: Notifications

1. **Create report** (as User A)
2. **Login as different user** (User B)
3. **Check "Notifications" tab**
4. **Should see**: Attestation request notification

### Test 5: Attestation

1. **View report** from notification
2. **Tap "Attest" button** (if available)
3. **Select action**: Confirm/Deny/Needs Info
4. **Submit**
5. **Verify**: Success message

## Common Issues & Fixes

### "No devices found"

```bash
# Start emulator first
flutter emulators --launch <emulator-id>

# Or connect physical device via USB
# Enable USB debugging on phone
```

### "Connection refused" / API errors

**For Android Emulator:**
- ✅ Backend must run on `0.0.0.0:8000` (already configured)
- ✅ App uses `10.0.2.2:8000` automatically (correct)

**For Physical Device:**
- Find your computer's IP:
  ```bash
  ipconfig getifaddr en0  # macOS
  ```
- Update `mobile/lib/api/client.dart` if needed:
  ```dart
  TalkamApiClient(baseUrl: 'http://YOUR_IP:8000/v1')
  ```

### Build errors

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### Gradle errors

```bash
cd mobile/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## Development Tips

### Hot Reload
- Press `r` in terminal → Hot reload
- Press `R` in terminal → Hot restart
- Press `q` in terminal → Quit app

### View Logs
```bash
# Flutter logs
flutter logs

# Backend logs
# Check terminal where uvicorn is running
```

### Debug Mode
- App runs in debug mode by default
- Can set breakpoints in VS Code/Android Studio
- Network requests visible in logs

## Testing Checklist

- [ ] App launches on emulator
- [ ] Can login/start anonymous session
- [ ] Device token registered (check backend logs)
- [ ] Can create report
- [ ] Can view reports feed
- [ ] Notifications work
- [ ] Attestation works
- [ ] Search/filter works

## Next Steps

1. ✅ Test basic functionality
2. ✅ Test new features
3. ⚙️ Configure Firebase for push notifications (optional)
4. ⚙️ Build release APK for distribution

---

**Ready to test!** Run `flutter run` and the app will launch on your Android device/emulator. 📱
