# Android Testing Setup - Complete ✅

## ✅ Setup Complete

### Mobile App Updates
- ✅ Device token service created
- ✅ API client methods added (`registerDeviceToken`, `listDeviceTokens`, `unregisterDeviceToken`)
- ✅ Auto-registration on login/register/anonymous
- ✅ Dependencies installed (`device_info_plus`, `package_info_plus`)
- ✅ Syntax errors fixed

### Backend
- ✅ Device token endpoints ready
- ✅ Push notification service ready
- ✅ All APIs working

## 🚀 Quick Test Run

### Step 1: Start Backend

**Terminal 1:**
```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Verify:** http://127.0.0.1:8000/health

### Step 2: Launch Android Emulator

```bash
flutter emulators --launch Medium_Phone_API_36.1
```

**Wait for:** Emulator to fully boot (home screen visible)

### Step 3: Run the App

**Terminal 2:**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter run
```

**First time:** Takes 2-3 minutes to build  
**Subsequent:** Much faster

## 🧪 What to Test

### 1. App Launch ✅
- App should open on emulator
- Welcome/login screen appears
- No crashes

### 2. Login/Anonymous ✅
- Tap "Start Anonymous" or login
- Home screen loads
- **Check backend logs**: Should see device token registration

### 3. Device Token Registration ✅
**After login, verify:**
- Backend terminal shows: `POST /v1/device-tokens/register`
- Database has entry: `SELECT * FROM device_tokens WHERE platform = 'android';`

### 4. Create Report ✅
- Tap "Create Report"
- Fill form and submit
- Report appears in feed

### 5. Notifications ✅
- Create report (User A)
- Login as User B
- Check Notifications tab
- See attestation request

### 6. Attestation ✅
- View report from notification
- Tap "Attest" button
- Submit attestation
- See success message

## 📊 Expected Backend Logs

```
INFO: POST /v1/auth/anonymous-start
INFO: POST /v1/device-tokens/register  ← Device token registered!
INFO: POST /v1/reports/create
INFO: POST /v1/attestations/reports/.../attest
```

## 🔍 Verification

### Check Device Token Registration

**Backend logs:**
```
POST /v1/device-tokens/register
{
  "token": "android_token_...",
  "platform": "android",
  "app_version": "0.1.0+1",
  "device_info": "Generic Android Device, Android 14"
}
```

**Database:**
```sql
SELECT platform, app_version, device_info, created_at 
FROM device_tokens 
ORDER BY created_at DESC;
```

## 🐛 Troubleshooting

### "No devices found"
```bash
flutter devices
flutter emulators --launch Medium_Phone_API_36.1
```

### "Connection refused"
- ✅ Backend must run on `0.0.0.0:8000`
- ✅ App uses `10.0.2.2:8000` (correct for emulator)
- ✅ Verify: `curl http://127.0.0.1:8000/health`

### Build errors
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## 📱 Development Tips

### Hot Reload
- `r` → Hot reload
- `R` → Hot restart
- `q` → Quit

### View Logs
```bash
flutter logs  # App logs
# Backend logs in Terminal 1
```

## Files Modified

- ✅ `mobile/lib/api/client.dart` - Device token methods
- ✅ `mobile/lib/services/device_token_service.dart` - New service
- ✅ `mobile/lib/screens/auth/login_screen.dart` - Auto-register on login
- ✅ `mobile/pubspec.yaml` - Dependencies added

## Next Steps

1. ✅ Launch emulator
2. ✅ Run `flutter run`
3. ✅ Test all features
4. ⚙️ Configure Firebase for real push notifications (optional)

---

**Ready to test!** Follow the 3 steps above. 📱

**Quick Command:**
```bash
# After backend is running:
flutter emulators --launch Medium_Phone_API_36.1 && sleep 15 && cd mobile && flutter run
```
