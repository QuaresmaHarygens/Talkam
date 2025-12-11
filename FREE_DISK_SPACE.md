# ⚠️ CRITICAL: Disk Space Full - Free Space First

## Current Status
- **Disk Usage**: 100% full (only 20MB free)
- **Gradle Cache**: 2.7GB (can be cleaned)
- **Cannot build APK** until space is freed

## 🧹 Quick Fix: Clean Gradle Cache

**Run these commands to free ~2.7GB:**

```bash
# Stop any running Gradle daemons
pkill -f gradle

# Clean Gradle cache (frees ~2.7GB)
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon

# Clean Flutter build cache
cd "/Users/visionalventure/Watch Liberia/mobile"
rm -rf build
rm -rf .dart_tool
rm -rf android/.gradle
rm -rf android/build
rm -rf android/app/build
```

## 📋 Additional Cleanup Options

### 1. Clean Flutter Cache
```bash
flutter clean
rm -rf ~/.flutter
```

### 2. Clean Android Studio Cache
```bash
rm -rf ~/Library/Caches/Google/AndroidStudio*
rm -rf ~/Library/Application\ Support/Google/AndroidStudio*/caches
```

### 3. Clean System Caches
```bash
# Clean system logs
sudo rm -rf /private/var/log/*

# Clean user caches
rm -rf ~/Library/Caches/*
```

### 4. Check Large Files
```bash
# Find large files
du -sh ~/* | sort -hr | head -20

# Find large directories
du -sh ~/.* 2>/dev/null | sort -hr | head -20
```

## 🎯 After Freeing Space

Once you have at least **2-3GB free**, build the APK:

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

## 📱 Build Commands

### Release APK (Recommended - Smaller)
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

**Output:** `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Debug APK (Larger)
```bash
flutter build apk --debug
```

**Output:** `mobile/build/app/outputs/flutter-apk/app-debug.apk`

## ⚠️ Important Notes

1. **Free space first** - You need at least 2-3GB free
2. **Gradle cache** - Safe to delete, will rebuild when needed
3. **Flutter build** - Will recreate build files
4. **Release APK** - Smaller and better for distribution

## 🔍 Check Available Space

```bash
df -h /
```

**You need at least 2-3GB free to build successfully.**

---

**Action Required:** Free up disk space before building APK.

