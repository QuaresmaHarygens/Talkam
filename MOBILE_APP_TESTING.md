# Mobile App Testing Guide - Full Display

Complete guide to run and view the Talkam Liberia mobile app.

## 🚀 Quick Start

### Step 1: Start the Backend API

Open Terminal 1:
```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

✅ Backend will be running at: http://127.0.0.1:8000
✅ API docs: http://127.0.0.1:8000/docs

### Step 2: Check Flutter Setup

Open Terminal 2:
```bash
# Check Flutter installation
flutter doctor

# Check available devices
flutter devices
```

### Step 3: Start an Emulator/Simulator

**For iOS (macOS only):**
```bash
# List available simulators
xcrun simctl list devices

# Open iOS Simulator
open -a Simulator

# Or launch specific simulator
flutter emulators --launch apple_ios_simulator
```

**For Android:**
```bash
# List available emulators
flutter emulators

# Launch Android emulator
flutter emulators --launch <emulator_id>

# Or use Android Studio:
# Tools → Device Manager → Start emulator
```

**Or use a physical device:**
- iOS: Connect iPhone/iPad via USB, enable Developer Mode
- Android: Connect phone via USB, enable USB Debugging

### Step 4: Run the Mobile App

```bash
cd mobile

# Get dependencies (first time only)
flutter pub get

# Run on connected device/emulator
flutter run

# Or run on specific device
flutter run -d <device-id>

# Run in release mode (faster, no hot reload)
flutter run --release
```

## 📱 What You'll See

### App Flow:

1. **Welcome Screen** 🎨
   - Speech bubble icon
   - "Welcome to Talkam Liberia" text
   - "Get started" button

2. **Login/Signup Screen** 🔐
   - Tab navigation (Log in / Sign up)
   - Phone number input
   - Password input
   - "Forget password?" link
   - "Anonymous mode" option

3. **Home Screen** 🏠
   - Recent reports feed
   - "New Report" button in header
   - Bottom navigation: Home, Map, Notifications, Settings

4. **Report Issue Screen** 📝
   - Category grid (Social, Economic, Religious, Political, Health, Violence)
   - Photo/Video button
   - Audio recording button
   - Text description field
   - "Report anonymously" checkbox
   - Submit button

5. **Report Details Screen** 📄
   - Report title
   - Verified badge (if verified)
   - Map view
   - Thread/Comments tabs

6. **Settings Screen** ⚙️
   - Sync options
   - Offline data
   - Delete my reports
   - Emergency hotlines
   - Two-factor authentication
   - Logout

## 🎯 Testing Credentials

**Admin User:**
- Phone: `231770000001`
- Password: `AdminPass123!`

**Regular User:**
- Phone: `231770000003`
- Password: `UserPass123!`

**Or create new account:**
- Use Sign up tab
- Enter full name, phone, password
- Email is optional

## 🔧 Development Features

### Hot Reload
While app is running:
- Press `r` in terminal → Hot reload (fast refresh)
- Press `R` in terminal → Hot restart (full restart)
- Press `q` in terminal → Quit app

### Debug Console
- View logs in terminal where you ran `flutter run`
- Errors and print statements appear here

### DevTools
```bash
# Open Flutter DevTools in browser
flutter pub global activate devtools
flutter pub global run devtools
```

## 📐 Screen Sizes & Display

### iOS Simulator
- Default: iPhone 15 Pro (393x852)
- Change device: Hardware → Device → Select device
- Rotate: Cmd + Left/Right Arrow

### Android Emulator
- Default: Pixel 7 (412x915)
- Change device: Edit AVD → Select device
- Rotate: Ctrl + F11 / Cmd + F11

### Physical Device
- Full native resolution
- Touch gestures work naturally
- Camera/microphone access

## 🐛 Troubleshooting

### "No devices found"
```bash
# Check devices
flutter devices

# For iOS: Open Simulator first
open -a Simulator

# For Android: Start emulator from Android Studio
```

### "Connection refused" or API errors
```bash
# Verify backend is running
curl http://127.0.0.1:8000/health

# For Android emulator, use 10.0.2.2 instead of 127.0.0.1
# Update mobile/lib/providers.dart or mobile/lib/api/client.dart:
# baseUrl: 'http://10.0.2.2:8000/v1'  // Android emulator
# baseUrl: 'http://127.0.0.1:8000/v1'  // iOS simulator
```

### Build errors
```bash
# Clean and rebuild
cd mobile
flutter clean
flutter pub get
flutter run
```

### App crashes on startup
- Check backend is running
- Verify API URL in code
- Check Flutter logs: `flutter logs`

### Media upload not working
- Verify S3/MinIO is configured
- Check file permissions
- Verify presigned URL generation

## 🎨 Viewing in Full Display

### Maximize Simulator/Emulator Window
- **iOS Simulator**: Window → Physical Size (Cmd + 1)
- **Android Emulator**: Drag corners to resize, or set scale in AVD settings

### Screenshots
```bash
# Take screenshot
flutter screenshot

# Or use simulator/emulator tools
# iOS: Device → Screenshot
# Android: Extended Controls → Camera
```

### Screen Recording
- **iOS Simulator**: QuickTime Player → New Movie Recording
- **Android Emulator**: Extended Controls → Screen Record

## 📋 Complete Test Checklist

- [ ] Welcome screen displays correctly
- [ ] Login/Signup tabs work
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Home screen shows reports
- [ ] Can create new report
- [ ] Category selection works
- [ ] Can add photo/video
- [ ] Can record audio
- [ ] Can submit report
- [ ] Can view report details
- [ ] Can delete reports
- [ ] Settings screen accessible
- [ ] Password reset works
- [ ] Offline queue works

## 🚀 Quick Commands Reference

```bash
# Start everything
# Terminal 1: Backend
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload

# Terminal 2: Mobile App
cd mobile && flutter run

# Or use the start script
./scripts/start_all.sh  # Starts backend + admin (mobile needs separate terminal)
```

## 📱 Device-Specific Notes

### iOS Simulator
- Best for testing iOS-specific features
- Fast startup
- No camera/mic access (use physical device for media)

### Android Emulator
- Best for testing Android-specific features
- Can test different screen sizes
- Camera/mic may need configuration

### Physical Device
- Best for real-world testing
- Full feature access (camera, mic, GPS)
- Network testing
- Performance testing

---

**Ready to see your app in full display! 🎨**
