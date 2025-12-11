# APK Build Summary 📱

## ⚠️ Current Status: Cannot Build - Disk Full

**Problem:** Your disk is 100% full (only 20MB free)  
**Solution:** Free up space first, then build

## 🚨 Action Required

### Step 1: Free Disk Space (REQUIRED)

**Clean Gradle cache to free ~2.7GB:**

```bash
# Stop Gradle
pkill -f gradle

# Clean cache
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon

# Clean Flutter build
cd "/Users/visionalventure/Watch Liberia/mobile"
rm -rf build android/.gradle android/build
```

**Verify space:**
```bash
df -h /
# Need at least 2-3GB free
```

### Step 2: Build APK (After Freeing Space)

**Release APK (Recommended):**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
flutter pub get
flutter build apk --release
```

**Output:** `mobile/build/app/outputs/flutter-apk/app-release.apk`

## 📦 Build Options

| Type | Command | Size | Use Case |
|------|---------|------|----------|
| **Release** | `flutter build apk --release` | ~20-40MB | Production, distribution |
| **Debug** | `flutter build apk --debug` | ~50-100MB | Testing, development |
| **Split** | `flutter build apk --split-per-abi` | ~10-20MB each | Smaller per architecture |

## 📱 Install APK

### On Emulator
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### On Physical Device
1. Transfer APK to device
2. Enable "Install from Unknown Sources"
3. Tap APK to install

## 📋 Quick Reference

**Free space first:**
```bash
rm -rf ~/.gradle/caches
```

**Then build:**
```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean && flutter pub get && flutter build apk --release
```

**Find APK:**
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## 🔍 Troubleshooting

- **"No space left"** → Free space first (see Step 1)
- **Build fails** → Run `flutter clean` then retry
- **Gradle errors** → Clean Gradle cache

---

**⚠️ IMPORTANT:** Free up at least 2-3GB before building!

**Current:** 20MB free (100% full)  
**Required:** 2-3GB free  
**Action:** Clean `~/.gradle/caches` first

