# Android Test Run - Step by Step Guide

## ✅ Prerequisites Check

Your system shows:
- ✅ Flutter installed (3.38.4)
- ✅ Android toolchain ready
- ⚠️ No Android emulator currently running

## Quick Start (3 Steps)

### Step 1: Start Backend Server

**Open Terminal 1:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Verify it's running:**
- Open browser: http://127.0.0.1:8000/health
- Should see: `{"status":"healthy","service":"talkam-api"}`

### Step 2: Start Android Emulator

**Option A: Using Flutter (Recommended)**
```bash
# List available emulators
flutter emulators

# Launch an emulator (replace with your emulator name)
flutter emulators --launch <emulator-name>

# Example:
flutter emulators --launch Pixel_5_API_33
```

**Option B: Using Android Studio**
1. Open Android Studio
2. Click "Device Manager" (phone icon in toolbar)
3. Click ▶️ Play button on an emulator
4. Wait for emulator to boot (home screen appears)

**Option C: Create New Emulator (if none exist)**
1. Open Android Studio
2. Tools → Device Manager
3. Click "Create Device"
4. Choose: Pixel 5 or Pixel 6
5. System Image: Latest Android (API 33+)
6. Finish setup
7. Click ▶️ to launch

**Verify emulator is running:**
```bash
flutter devices
# Should show: sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64
```

### Step 3: Run the App

**Open Terminal 2:**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"

# Install dependencies (first time only)
flutter pub get

# Run the app
flutter run
```

**What happens:**
1. Flutter builds the app (first time: 2-3 minutes)
2. Installs on emulator
3. Launches automatically
4. Shows welcome/login screen

## Testing Features

### Test 1: Basic App Launch ✅
- App should launch and show welcome/login screen
- No crashes or errors

### Test 2: Login/Anonymous Session
1. **Tap "Start Anonymous"** or login with:
   - Phone: `231770000003`
   - Password: `UserPass123!`
2. **Verify**: Home screen loads
3. **Check backend logs**: Should see device token registration

### Test 3: Device Token Registration
**After login, check:**
- Backend terminal should show: `POST /v1/device-tokens/register`
- Or check database:
  ```sql
  SELECT * FROM device_tokens WHERE platform = 'android';
  ```

### Test 4: Create Report
1. **Tap "Create Report"** button
2. **Fill form**:
   - Category: Infrastructure
   - Severity: High
   - Summary: "Test report from Android"
3. **Allow location** when prompted
4. **Submit**
5. **Verify**: Report appears in feed

### Test 5: Notifications
1. **Create report** (as User A)
2. **Login as different user** (User B)
3. **Tap "Notifications" tab**
4. **Should see**: Attestation request

### Test 6: Attestation
1. **View report** from notification
2. **Tap "Attest" button** (if shown)
3. **Select**: Confirm/Deny/Needs Info
4. **Submit**
5. **Verify**: Success message

## Troubleshooting

### "No devices found"

**Solution:**
```bash
# Start emulator first
flutter emulators --launch <emulator-name>

# Or check devices
flutter devices

# Wait for emulator to fully boot (home screen visible)
```

### "Connection refused" / API errors

**For Android Emulator:**
- ✅ App automatically uses `10.0.2.2:8000` (correct)
- ✅ Backend must run on `0.0.0.0:8000` (already configured)

**Verify backend is accessible:**
```bash
# From emulator shell
adb shell
curl http://10.0.2.2:8000/health
```

### Build errors / Dependency issues

**Solution:**
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### "Waiting for another flutter command"

**Solution:**
```bash
# Kill any stuck Flutter processes
killall -9 dart
killall -9 flutter

# Try again
flutter run
```

## Development Tips

### Hot Reload
While app is running:
- Press `r` → Hot reload (fast)
- Press `R` → Hot restart (full restart)
- Press `q` → Quit app

### View Logs
```bash
# Flutter app logs
flutter logs

# Backend logs
# Check Terminal 1 where uvicorn is running
```

### Debug Mode
- App runs in debug mode by default
- Can set breakpoints in VS Code/Android Studio
- Network requests visible in logs

## Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor

# List devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <name>

# Run app
flutter run

# Build APK
flutter build apk --debug
```

## Expected Results

### Backend Logs (Terminal 1)
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     POST /v1/auth/anonymous-start
INFO:     POST /v1/device-tokens/register
INFO:     POST /v1/reports/create
```

### App Behavior
- ✅ Launches without errors
- ✅ Can login/register
- ✅ Can create reports
- ✅ Can view reports feed
- ✅ Notifications work
- ✅ Attestation works

## Next Steps After Testing

1. ✅ Verify all features work
2. ⚙️ Configure Firebase for real push notifications
3. ⚙️ Build release APK for distribution
4. ⚙️ Test on physical Android device

---

**Ready to test!** Follow the 3 steps above and the app will run on Android. 📱
