# How to Test Run on Android - Complete Guide 📱

## ✅ Your System is Ready!

- ✅ Flutter installed (3.38.4)
- ✅ Android toolchain ready
- ✅ Emulator available: `Medium_Phone_API_36.1`
- ✅ Dependencies installed
- ✅ Device token service integrated
- ✅ All code ready

## 🚀 Quick Start (3 Simple Steps)

### Step 1: Start Backend Server

**Open Terminal 1:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**✅ Verify it's running:**
- Open browser: http://127.0.0.1:8000/health
- Should see: `{"status":"healthy","service":"talkam-api"}`

### Step 2: Launch Android Emulator

**Open Terminal 2:**
```bash
flutter emulators --launch Medium_Phone_API_36.1
```

**Wait for:**
- Emulator window opens
- Android home screen appears (takes 15-30 seconds)
- No loading indicators

**✅ Verify emulator is ready:**
```bash
flutter devices
# Should show: sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64
```

### Step 3: Run the App

**In Terminal 2 (same terminal, after emulator boots):**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter run
```

**What happens:**
1. Flutter builds the app (first time: 2-3 minutes)
2. Installs on emulator automatically
3. Launches the app
4. Shows welcome/login screen

## 🧪 Testing the App

### Test 1: Basic Launch ✅
- App should open without errors
- Welcome/login screen appears

### Test 2: Login/Anonymous Session
1. **Tap "Start Anonymous"** button
2. **Or login with:**
   - Phone: `231770000003`
   - Password: `UserPass123!`
3. **Verify**: Home screen loads

### Test 3: Device Token Registration ⭐ NEW FEATURE
**After login, check Terminal 1 (backend):**
- Should see: `POST /v1/device-tokens/register`
- This means device token was registered!

**Or check database:**
```sql
SELECT platform, app_version, device_info, created_at 
FROM device_tokens 
WHERE platform = 'android'
ORDER BY created_at DESC;
```

### Test 4: Create Report
1. **Tap "Create Report"** button
2. **Fill in:**
   - Category: Infrastructure
   - Severity: High
   - Summary: "Test report from Android"
3. **Allow location** when prompted
4. **Submit**
5. **Verify**: Report appears in feed

### Test 5: Notifications ⭐ NEW FEATURE
1. **Create a report** (as User A)
2. **Login as different user** (User B)
3. **Tap "Notifications" tab** (bottom navigation)
4. **Should see**: Attestation request notification

### Test 6: Attestation ⭐ NEW FEATURE
1. **Tap notification** to view report
2. **Tap "Attest" button** (if shown in app bar)
3. **Select action**: Confirm/Deny/Needs Info
4. **Add confidence**: High/Medium/Low
5. **Submit**
6. **Verify**: Success message

## 📊 What You Should See

### Backend Logs (Terminal 1)
```
INFO:     POST /v1/auth/anonymous-start
INFO:     POST /v1/device-tokens/register  ← Device token registered!
INFO:     POST /v1/reports/create
INFO:     POST /v1/notifications (if other users exist)
INFO:     POST /v1/attestations/reports/.../attest
```

### App Behavior
- ✅ Smooth navigation
- ✅ No crashes
- ✅ API calls succeed
- ✅ Data loads correctly
- ✅ Device token registered automatically

## 🐛 Troubleshooting

### Issue: "No devices found"

**Solution:**
```bash
# Check devices
flutter devices

# If none, launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# Wait 15 seconds, then check again
flutter devices
```

### Issue: "Connection refused" / API errors

**For Android Emulator:**
- ✅ App automatically uses `10.0.2.2:8000` (correct)
- ✅ Backend must run on `0.0.0.0:8000` (already configured)

**Verify:**
```bash
# From emulator shell
adb shell
curl http://10.0.2.2:8000/health
```

### Issue: Build takes too long

**First build:** 2-3 minutes (normal)  
**Subsequent:** Much faster

**If stuck:**
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### Issue: App crashes

**Check logs:**
```bash
flutter logs
```

**Check backend:**
- Is backend running?
- Check Terminal 1 for errors

## 💡 Development Tips

### Hot Reload (While App is Running)
- Press `r` → Hot reload (fast, keeps state)
- Press `R` → Hot restart (full restart)
- Press `q` → Quit app

### View Logs
```bash
# App logs
flutter logs

# Backend logs
# Check Terminal 1 where uvicorn is running
```

### Debug Mode
- App runs in debug mode by default
- Can set breakpoints in VS Code/Android Studio
- Network requests visible in logs

## 📋 Complete Testing Checklist

- [ ] Backend running (Terminal 1)
- [ ] Emulator launched and booted
- [ ] App launches successfully
- [ ] Can login/start anonymous session
- [ ] Device token registered (check backend logs)
- [ ] Can create report
- [ ] Can view reports feed
- [ ] Notifications tab works
- [ ] Can attest to reports
- [ ] Search/filter works

## 🎯 Quick Reference Commands

```bash
# Check Flutter setup
flutter doctor

# List devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# Run app
cd mobile && flutter run

# View logs
flutter logs

# Hot reload (while app running)
# Press 'r' in terminal
```

## 📱 Expected App Flow

1. **Welcome Screen** → Tap "Get Started"
2. **Login Screen** → Tap "Start Anonymous" or login
3. **Home Screen** → Shows tabs (Reports, Map, Notifications, Settings)
4. **Create Report** → Fill form, submit
5. **Reports Feed** → See your report
6. **Notifications** → See attestation requests (if any)

## 🔍 Verifying New Features

### Device Token Registration
**Check Terminal 1 (backend):**
```
INFO: POST /v1/device-tokens/register
```

**Or database:**
```sql
SELECT * FROM device_tokens WHERE platform = 'android';
```

### Push Notifications
- Currently in stub mode (works without FCM)
- Real push notifications require Firebase setup
- Notifications still work (in-app)

### Advanced Search
- Use search bar in Reports feed
- Filter by category, severity, etc.

## 🎉 Success Indicators

✅ **App launches** without errors  
✅ **Can login** successfully  
✅ **Device token registered** (check backend logs)  
✅ **Can create reports**  
✅ **Notifications work**  
✅ **Attestation works**  

## Next Steps After Testing

1. ✅ Verify all features work
2. ⚙️ Configure Firebase for real push notifications (optional)
3. ⚙️ Test on physical Android device
4. ⚙️ Build release APK for distribution

---

## 🚀 Ready to Test!

**Run these 3 commands:**

```bash
# Terminal 1: Backend
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Terminal 2: Emulator & App
flutter emulators --launch Medium_Phone_API_36.1
# Wait 15 seconds, then:
cd mobile && flutter run
```

**The app will launch on Android and you can test all features!** 📱

---

**Need help?** Check `ANDROID_TESTING_GUIDE.md` for detailed troubleshooting.
