# ⚡ Quick Fix: Use ngrok (5 Minutes) 🚀

## Why ngrok?

**ngrok bypasses ALL network issues:**
- ✅ No firewall problems
- ✅ No IP address changes
- ✅ Works on any network
- ✅ HTTPS (secure)
- ✅ Most reliable solution

## 🚀 Quick Setup (5 Steps)

### Step 1: Install ngrok

```bash
brew install ngrok
```

**Or download from:** https://ngrok.com/download

### Step 2: Start Backend (if not running)

```bash
cd "/Users/visionalventure/Watch Liberia/backend"
source .venv/bin/activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### Step 3: Start ngrok Tunnel

**Open new terminal:**
```bash
ngrok http 8000
```

**You'll see:**
```
Forwarding  https://abc123xyz.ngrok-free.app -> http://localhost:8000
```

**Copy the HTTPS URL** (e.g., `https://abc123xyz.ngrok-free.app`)

### Step 4: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

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

### Step 5: Rebuild and Install APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

**Install on device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Or transfer manually and install.**

## ✅ Done!

**Your app will now connect via ngrok - no more connection errors!**

## 🔄 Keeping ngrok Running

**Keep ngrok terminal open while testing.**

**To stop ngrok:** Press `Ctrl+C` in ngrok terminal

**To restart:** Run `ngrok http 8000` again (URL will change)

## 💡 Pro Tip: Use ngrok Authtoken (Optional)

**For stable URLs (paid feature) or free account:**

```bash
# Sign up at ngrok.com (free)
# Get authtoken from dashboard
ngrok config add-authtoken YOUR_TOKEN
```

**Free tier gives you:**
- Random URLs (changes each restart)
- Sufficient for testing

## 🎯 Why This Works

- ngrok creates a **public HTTPS tunnel**
- Your phone connects to **ngrok's servers**
- ngrok forwards to your **local backend**
- **No firewall, no IP issues, no network problems!**

---

**This is the most reliable solution - try it now!** ⚡



