# Android Quick Start - Test Run Guide 📱

## ✅ Your Setup Status

- ✅ Flutter installed (3.38.4)
- ✅ Android toolchain ready
- ✅ Emulator available: `Medium_Phone_API_36.1`
- ✅ Dependencies installed
- ✅ Device token service integrated

## 🚀 Quick Start (3 Commands)

### Terminal 1: Start Backend
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Terminal 2: Launch Emulator & Run App
```bash
# Launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# Wait 10-15 seconds for emulator to boot, then:
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter run
```

**OR use the automated script:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/run_android_test.sh
```

## 📋 Step-by-Step

### Step 1: Verify Backend is Running

Open browser: http://127.0.0.1:8000/health

Should see: `{"status":"healthy","service":"talkam-api"}`

### Step 2: Launch Android Emulator

```bash
flutter emulators --launch Medium_Phone_API_36.1
```

**Wait for:**
- Emulator window opens
- Android home screen appears
- No loading indicators

### Step 3: Run the App

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter run
```

**First time:**
- Build takes 2-3 minutes
- App installs automatically
- Launches on emulator

**Subsequent runs:**
- Much faster (hot reload)

## 🧪 Testing Checklist

### Basic Functionality
- [ ] App launches (welcome/login screen)
- [ ] Can tap "Start Anonymous" or login
- [ ] Home screen loads after login
- [ ] Can navigate between tabs

### Device Token Registration
- [ ] After login, check backend terminal
- [ ] Should see: `POST /v1/device-tokens/register`
- [ ] Or check database: `SELECT * FROM device_tokens;`

### Report Creation
- [ ] Tap "Create Report" button
- [ ] Fill form (category, severity, summary)
- [ ] Allow location permission
- [ ] Submit report
- [ ] Report appears in feed

### Notifications
- [ ] Create report (as User A)
- [ ] Login as different user (User B)
- [ ] Check "Notifications" tab
- [ ] Should see attestation request

### Attestation
- [ ] View report from notification
- [ ] Tap "Attest" button
- [ ] Select action (Confirm/Deny/Needs Info)
- [ ] Submit
- [ ] See success message

## 🔍 What to Look For

### Backend Logs (Terminal 1)
```
INFO: POST /v1/auth/anonymous-start
INFO: POST /v1/device-tokens/register  ← Device token registered!
INFO: POST /v1/reports/create
INFO: POST /v1/attestations/reports/.../attest
```

### App Behavior
- ✅ Smooth navigation
- ✅ No crashes
- ✅ API calls succeed
- ✅ Data loads correctly

## 🐛 Common Issues

### "No devices found"
```bash
# Check devices
flutter devices

# If none, launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# Wait for it to boot, then try again
flutter run
```

### "Connection refused"
- ✅ Backend must run on `0.0.0.0:8000` (already configured)
- ✅ App uses `10.0.2.2:8000` automatically (correct for emulator)
- ✅ Verify backend is running: `curl http://127.0.0.1:8000/health`

### Build errors
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### App crashes on launch
- Check Flutter logs: `flutter logs`
- Check backend logs for errors
- Verify all dependencies installed: `flutter pub get`

## 💡 Development Tips

### Hot Reload
While app is running:
- Press `r` → Hot reload (fast)
- Press `R` → Hot restart
- Press `q` → Quit

### View Logs
```bash
# App logs
flutter logs

# Backend logs
# Check Terminal 1
```

### Debug Mode
- App runs in debug mode
- Can set breakpoints
- Network requests visible

## 📊 Expected Results

### Device Token Registration
After login, you should see in backend logs:
```
POST /v1/device-tokens/register
{
  "token": "android_token_...",
  "platform": "android",
  "app_version": "0.1.0+1"
}
```

### Database Check
```sql
SELECT platform, app_version, device_info, created_at 
FROM device_tokens 
ORDER BY created_at DESC 
LIMIT 5;
```

## 🎯 Test Credentials

**Regular User:**
- Phone: `231770000003`
- Password: `UserPass123!`

**Admin User:**
- Phone: `231770000001`
- Password: `AdminPass123!`

## Next Steps

1. ✅ Test basic functionality
2. ✅ Verify device token registration
3. ✅ Test all new features
4. ⚙️ Configure Firebase for real push notifications (optional)
5. ⚙️ Build release APK for distribution

---

**Ready to test!** Run the commands above and the app will launch on Android. 📱

**Quick Command:**
```bash
# All in one (after backend is running):
flutter emulators --launch Medium_Phone_API_36.1 && sleep 15 && cd mobile && flutter run
```
