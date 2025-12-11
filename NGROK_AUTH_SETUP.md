# ngrok Authentication Setup 🔐

## ⚠️ Issue

ngrok requires a free account and authtoken to use.

## ✅ Solution: Sign Up (Free, 2 Minutes)

### Step 1: Sign Up for Free Account

1. **Go to:** https://dashboard.ngrok.com/signup
2. **Sign up** with email (free account)
3. **Verify your email** (check inbox)

### Step 2: Get Your Authtoken

1. **After signing up, go to:** https://dashboard.ngrok.com/get-started/your-authtoken
2. **Copy your authtoken** (long string of characters)

### Step 3: Configure ngrok

**Run this command (replace YOUR_TOKEN with your actual token):**

```bash
ngrok config add-authtoken YOUR_TOKEN_HERE
```

**Example:**
```bash
ngrok config add-authtoken 2abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

### Step 4: Verify Setup

```bash
ngrok http 8000
```

**Should now work without errors!**

## 🚀 Quick Setup Commands

**After getting your authtoken:**

```bash
# Add authtoken
ngrok config add-authtoken YOUR_TOKEN

# Start tunnel
ngrok http 8000
```

## 📋 Alternative: USB Port Forwarding (No Sign Up Needed)

**If you don't want to sign up for ngrok, use USB forwarding instead:**

### Setup USB Forwarding:

```bash
# 1. Connect phone via USB
adb devices  # Verify connected

# 2. Forward port
adb reverse tcp:8000 tcp:8000

# 3. Verify
adb reverse --list
```

### Update App:

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'http://127.0.0.1:8000/v1',  // Use localhost via USB
));
```

**Then rebuild APK:**
```bash
cd mobile
flutter build apk --release
```

**✅ This works without any sign-up!**

## 🎯 Recommendation

**Option 1: ngrok (Recommended)**
- ✅ Free account (takes 2 minutes)
- ✅ Works wirelessly
- ✅ Most reliable
- ✅ Can test from anywhere

**Option 2: USB Forwarding**
- ✅ No sign-up needed
- ✅ Works immediately
- ⚠️ Requires USB connection
- ✅ Still very reliable

---

**Choose one:**
1. **Sign up for ngrok** (free, 2 min) → Most flexible
2. **Use USB forwarding** → No sign-up needed



