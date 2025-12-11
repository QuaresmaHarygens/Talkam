# ngrok Setup Guide - Step by Step 🚀

## ✅ Step 1: Install ngrok

**Installation:**
```bash
brew install ngrok
```

**Verify installation:**
```bash
ngrok version
```

## ✅ Step 2: Start Backend (Terminal 1)

**Make sure backend is running:**

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

**Keep this terminal open!**

## ✅ Step 3: Start ngrok Tunnel (Terminal 2)

**Open a new terminal and run:**

```bash
ngrok http 8000
```

**Or use the script:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/start_ngrok.sh
```

**You'll see output like:**
```
Session Status                online
Account                       (your account)
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123xyz.ngrok-free.app -> http://localhost:8000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

**📋 Copy the HTTPS URL** (e.g., `https://abc123xyz.ngrok-free.app`)

**Keep this terminal open too!**

## ✅ Step 4: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

**Replace the baseUrl with your ngrok URL:**

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-NGROK-URL.ngrok-free.app/v1',  // Paste your ngrok URL here
));
```

**Example:**
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://abc123xyz.ngrok-free.app/v1',
));
```

**Important:** 
- Use the **HTTPS URL** (starts with `https://`)
- Include `/v1` at the end
- No trailing slash

## ✅ Step 5: Rebuild APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

**This will take a few minutes.**

## ✅ Step 6: Install New APK

**Option A: Via USB (ADB)**
```bash
adb install "/Users/visionalventure/Watch Liberia/mobile/build/app/outputs/flutter-apk/app-release.apk"
```

**Option B: Transfer Manually**
- Transfer APK to device
- Uninstall old app first
- Install new APK

## ✅ Step 7: Test!

1. **Open app on device**
2. **Try "Start Anonymous" or login**
3. **Should connect successfully!** ✅

## 🔍 Verify ngrok is Working

**Test ngrok URL from phone browser:**
1. Open browser on phone
2. Go to: `https://YOUR-NGROK-URL.ngrok-free.app/health`
3. Should see: `{"status":"healthy","service":"talkam-api"}`

**If this works, app will work too!**

## ⚠️ Important Notes

### Keep ngrok Running
- **Keep ngrok terminal open** while testing
- If you close it, the URL stops working
- Restart ngrok to get a new URL (free tier)

### URL Changes
- **Free tier:** URL changes each time you restart ngrok
- **Paid tier:** Can get static URLs
- **For testing:** Free tier is fine

### ngrok Web Interface
- Visit: `http://127.0.0.1:4040` in browser
- See all requests going through ngrok
- Useful for debugging

## 🎯 Quick Checklist

- [ ] ngrok installed
- [ ] Backend running on port 8000
- [ ] ngrok tunnel started
- [ ] Copied HTTPS URL from ngrok
- [ ] Updated `mobile/lib/providers.dart` with ngrok URL
- [ ] Rebuilt APK
- [ ] Installed new APK on device
- [ ] Tested from phone browser (optional)
- [ ] Tested app - connection works!

## 🐛 Troubleshooting

### "ngrok: command not found"
```bash
brew install ngrok
```

### "tunnel session failed"
- Check backend is running on port 8000
- Check port 8000 is not in use: `lsof -i :8000`

### "Connection refused" in app
- Verify ngrok URL is correct in `providers.dart`
- Check ngrok is still running
- Rebuild APK after updating URL

### URL not working
- ngrok might have stopped
- Restart ngrok to get new URL
- Update app with new URL and rebuild

## 📋 Summary

1. ✅ Install ngrok: `brew install ngrok`
2. ✅ Start backend: `uvicorn app.main:app --reload --host 127.0.0.1 --port 8000`
3. ✅ Start ngrok: `ngrok http 8000`
4. ✅ Copy HTTPS URL
5. ✅ Update `mobile/lib/providers.dart` with ngrok URL
6. ✅ Rebuild APK: `flutter build apk --release`
7. ✅ Install new APK
8. ✅ Test app - should work! 🎉

---

**Follow these steps and your connection will work!** ✅



