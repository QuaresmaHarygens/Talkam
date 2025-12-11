# LocalTunnel Setup - Best Alternative! 🚀

## ✅ Why LocalTunnel?

- ✅ **No sign-up required**
- ✅ **Free forever**
- ✅ **Works immediately**
- ✅ **Bypasses all firewall/network issues**
- ✅ **HTTPS (secure)**
- ✅ **Most reliable alternative**

## 🚀 Quick Setup (5 Steps)

### Step 1: Install Node.js (if not installed)

```bash
brew install node
```

**Verify installation:**
```bash
node --version
npm --version
```

### Step 2: Start LocalTunnel

**No installation needed - runs directly:**

```bash
npx localtunnel --port 8000
```

**You'll see output like:**
```
your url is: https://abc123xyz.loca.lt
```

**📋 Copy the HTTPS URL!**

### Step 3: Keep Tunnel Running

**Keep this terminal open while testing!**

**To stop:** Press `Ctrl+C`

**To restart:** Run `npx localtunnel --port 8000` again (URL will change)

### Step 4: Update App Configuration

**Edit:** `mobile/lib/providers.dart`

```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://YOUR-LOCALTUNNEL-URL.loca.lt/v1',  // Paste your LocalTunnel URL
));
```

**Example:**
```dart
final apiClientProvider = Provider((ref) => TalkamApiClient(
  baseUrl: 'https://abc123xyz.loca.lt/v1',
));
```

**Important:**
- Use the **HTTPS URL** (starts with `https://`)
- Include `/v1` at the end
- No trailing slash

### Step 5: Rebuild and Install APK

```bash
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter build apk --release
```

**Install on device:**
```bash
adb install "/Users/visionalventure/Watch Liberia/mobile/build/app/outputs/flutter-apk/app-release.apk"
```

## ✅ Test Connection

### From Phone Browser (Optional):

1. **Open browser on phone**
2. **Go to:** `https://YOUR-LOCALTUNNEL-URL.loca.lt/health`
3. **Should see:** `{"status":"healthy","service":"talkam-api"}`

**If this works, app will work too!**

### From App:

1. **Open app on device**
2. **Try "Start Anonymous" or login**
3. **Should connect successfully!** ✅

## 🔍 Troubleshooting

### "npx: command not found"

**Install Node.js:**
```bash
brew install node
```

### "Port 8000 already in use"

**Check what's using port 8000:**
```bash
lsof -i :8000
```

**Kill the process or use different port:**
```bash
npx localtunnel --port 8080
```

### URL Not Working

**LocalTunnel URLs change each time you restart.**

**If URL stops working:**
1. Restart tunnel: `npx localtunnel --port 8000`
2. Get new URL
3. Update app with new URL
4. Rebuild APK

### Connection Timeout

**Make sure:**
- Backend is running on port 8000
- LocalTunnel is running
- You're using the correct URL

## 💡 Pro Tips

### Keep Tunnel Running

**Use `screen` or `tmux` to keep tunnel running in background:**

```bash
# Install screen
brew install screen

# Start screen session
screen -S tunnel

# Run LocalTunnel
npx localtunnel --port 8000

# Detach: Press Ctrl+A then D
# Reattach: screen -r tunnel
```

### Use Custom Subdomain (Optional)

**For stable URLs (requires sign-up, but free):**

```bash
npx localtunnel --port 8000 --subdomain yourname
# URL: https://yourname.loca.lt
```

## 📋 Quick Command Reference

```bash
# Start tunnel
npx localtunnel --port 8000

# With custom subdomain (optional)
npx localtunnel --port 8000 --subdomain yourname

# Check Node.js installed
node --version

# Install Node.js if needed
brew install node
```

## ✅ Advantages Over Other Solutions

- ✅ **No sign-up** (unlike ngrok)
- ✅ **No USB needed** (unlike USB forwarding)
- ✅ **No WiFi issues** (unlike network IP)
- ✅ **Works from anywhere** (unlike local network)
- ✅ **HTTPS** (secure)
- ✅ **Free forever**

---

**This is the best solution - try it now!** 🚀



