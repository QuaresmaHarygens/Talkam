# Build APK Instructions 📱

## ⚠️ CRITICAL: Disk Space Issue

**Your disk is 100% full (only 20MB free).**

**You MUST free up space before building the APK.**

## 🚨 Immediate Action Required

### Step 1: Free Up Disk Space

**Quick fix - Clean Gradle cache (frees ~2.7GB):**

```bash
# Stop Gradle processes
pkill -f gradle

# Delete Gradle cache
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon

# Clean Flutter build
cd "/Users/visionalventure/Watch Liberia/mobile"
rm -rf build
rm -rf android/.gradle
rm -rf android/build
```

**Verify space freed:**
```bash
df -h /
# You need at least 2-3GB free
```

### Step 2: Build APK

**After freeing space, run:**

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

**OR use the automated script:**
```bash
cd "/Users/visionalventure/Watch Liberia"
./scripts/clean_and_build_apk.sh
```

## 📦 APK Build Options

### Release APK (Recommended)
```bash
flutter build apk --release
```
- ✅ Smaller file size (~20-40MB)
- ✅ Optimized for production
- ✅ Better performance
- **Location:** `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Debug APK
```bash
flutter build apk --debug
```
- ⚠️ Larger file size (~50-100MB)
- ✅ Includes debug symbols
- **Location:** `mobile/build/app/outputs/flutter-apk/app-debug.apk`

### Split APKs (by architecture)
```bash
flutter build apk --split-per-abi
```
- ✅ Smaller individual files (~10-20MB each)
- ✅ Separate APKs for ARM32, ARM64, x86
- **Location:** `mobile/build/app/outputs/flutter-apk/`

## 📱 Installing the APK

### On Emulator
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### On Physical Device
1. Transfer APK to device (via USB, email, etc.)
2. Enable "Install from Unknown Sources" in Android settings
3. Tap the APK file to install

## 🔍 Troubleshooting

### "No space left on device"
- **Solution:** Free up space first (see Step 1 above)
- Clean Gradle cache: `rm -rf ~/.gradle/caches`
- Clean Flutter build: `flutter clean`

### Build fails
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### Gradle errors
```bash
cd mobile/android
./gradlew clean
cd ..
flutter clean
flutter build apk --release
```

## ✅ Success Checklist

Before building:
- [ ] At least 2-3GB free disk space
- [ ] Flutter dependencies installed: `flutter pub get`
- [ ] Flutter setup verified: `flutter doctor`
- [ ] Previous builds cleaned: `flutter clean`

After building:
- [ ] APK file exists in `build/app/outputs/flutter-apk/`
- [ ] APK size is reasonable (20-40MB for release)
- [ ] Can install APK on device/emulator

## 📊 Expected Results

### Release APK
- **File:** `app-release.apk`
- **Size:** ~20-40MB
- **Location:** `mobile/build/app/outputs/flutter-apk/`
- **Build time:** 5-10 minutes (first time)

### Debug APK
- **File:** `app-debug.apk`
- **Size:** ~50-100MB
- **Location:** `mobile/build/app/outputs/flutter-apk/`
- **Build time:** 3-5 minutes

## 🎯 Quick Command Summary

```bash
# 1. Free space (if needed)
rm -rf ~/.gradle/caches

# 2. Build release APK
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release

# 3. Find APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚠️ IMPORTANT

**You cannot build the APK until you free up disk space.**

**Minimum required:** 2-3GB free

**Current status:** 20MB free (100% full)

**Action:** Clean Gradle cache first, then build.

