# Android Emulator Setup Guide

Complete guide to set up Android Studio and run the app on Android Emulator.

## 📋 Prerequisites Check

### Step 1: Check if Android Studio is Installed

```bash
# Check if Android Studio exists
ls /Applications/ | grep -i android

# Or check Flutter doctor
flutter doctor
```

## 🚀 Installation Steps

### Option A: Install Android Studio (Recommended)

1. **Download Android Studio:**
   - Visit: https://developer.android.com/studio
   - Download for macOS
   - Or use Homebrew: `brew install --cask android-studio`

2. **Install Android Studio:**
   - Open the downloaded .dmg
   - Drag Android Studio to Applications
   - Launch Android Studio

3. **First Launch Setup:**
   - Choose "Standard" installation
   - Let it download Android SDK components
   - Accept licenses when prompted

4. **Set Environment Variables:**
   
   Add to `~/.zshrc` or `~/.bash_profile`:
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/emulator
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   export PATH=$PATH:$ANDROID_HOME/tools/bin
   ```
   
   Then reload:
   ```bash
   source ~/.zshrc
   ```

5. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   # Press 'y' for each license
   ```

### Option B: Install Command Line Tools Only (Lightweight)

If you don't want full Android Studio:

```bash
# Install via Homebrew
brew install --cask android-commandlinetools

# Set up SDK
mkdir -p ~/Library/Android/sdk
export ANDROID_HOME=~/Library/Android/sdk

# Install SDK components
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
sdkmanager "emulator" "system-images;android-33;google_apis;x86_64"

# Accept licenses
yes | sdkmanager --licenses
```

## 📱 Create Android Virtual Device (AVD)

### Using Android Studio GUI:

1. **Open Android Studio**
2. **Tools → Device Manager**
3. **Create Device** button
4. **Select Device:**
   - Choose: Pixel 7 (or any device)
   - Click Next
5. **Select System Image:**
   - Choose: Latest API level (e.g., API 34)
   - Download if needed
   - Click Next
6. **Configure AVD:**
   - Name: `pixel_7_api_34`
   - Click Finish

### Using Command Line:

```bash
# List available system images
sdkmanager --list | grep system-images

# Create AVD
avdmanager create avd -n pixel_7_api_34 \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_7"
```

## 🚀 Launch Android Emulator

### Method 1: Using Flutter

```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Or launch and run app
flutter run -d <emulator_id>
```

### Method 2: Using Android Studio

1. Open Android Studio
2. Tools → Device Manager
3. Click ▶️ (Play) button next to your AVD

### Method 3: Using Command Line

```bash
# List AVDs
emulator -list-avds

# Launch AVD
emulator -avd <avd_name> &

# Or with specific options
emulator -avd pixel_7_api_34 -netdelay none -netspeed full
```

## 📱 Run Your App on Android

Once emulator is running:

```bash
cd mobile

# Check devices
flutter devices

# Run app
flutter run -d android

# Or specify device ID
flutter run -d <device-id>
```

## 🎨 Viewing in Full Display

### Android Emulator Display Options:

1. **Resize Window:**
   - Drag corners to resize
   - Or: Extended Controls (⋯) → Settings → Scale display

2. **Full Screen:**
   - Extended Controls → Settings → Scale → Auto
   - Or: Window → Zoom → Fit to Screen

3. **Rotate Device:**
   - Extended Controls → Rotate
   - Or: Ctrl + F11 (Cmd + F11 on Mac)

4. **Screen Recording:**
   - Extended Controls → Screen Record

## 🔧 Troubleshooting

### "Android SDK not found"
```bash
# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Verify
echo $ANDROID_HOME
```

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### "No emulators found"
```bash
# Create AVD first (see above)
# Or use Android Studio Device Manager
```

### "Emulator won't start"
```bash
# Check if virtualization is enabled
# For Intel Macs: Enable in System Preferences
# For Apple Silicon: Should work natively

# Try cold boot
emulator -avd <avd_name> -wipe-data
```

### "App won't connect to backend"
```bash
# Android emulator uses special IP for localhost
# Update mobile/lib/api/client.dart:
# baseUrl: 'http://10.0.2.2:8000/v1'  // For Android emulator
```

## ✅ Verification

Check everything is set up:

```bash
flutter doctor -v
```

Should show:
- ✅ Android toolchain
- ✅ Android licenses accepted
- ✅ Connected device (when emulator is running)

## 🎯 Quick Start Commands

```bash
# 1. Start backend
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload

# 2. Launch Android emulator
flutter emulators --launch <emulator_id>

# 3. Run app
cd mobile && flutter run -d android
```

---

**Ready to run on Android! 🤖**
