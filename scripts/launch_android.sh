#!/bin/bash

# Launch Talkam Liberia on Android Emulator

echo "🤖 Launching Talkam Liberia on Android"
echo "======================================"
echo ""

# Set Android environment
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

# Check backend
echo "1️⃣  Checking backend..."
if curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; then
  echo "✅ Backend is running"
else
  echo "⚠️  Backend not running. Starting in background..."
  cd backend
  source .venv/bin/activate 2>/dev/null || python3 -m venv .venv && source .venv/bin/activate
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 > ../backend.log 2>&1 &
  echo "Backend started. Logs: backend.log"
  sleep 3
  cd ..
fi

# Check emulator
echo ""
echo "2️⃣  Checking Android emulator..."
EMULATOR_ID=$(flutter emulators | grep -oE "^\s+\S+" | head -1 | xargs)
if [ -z "$EMULATOR_ID" ]; then
  echo "❌ No emulator found"
  echo "   Please create one in Android Studio: Tools → Device Manager"
  exit 1
fi

echo "✅ Found emulator: $EMULATOR_ID"

# Launch emulator
echo ""
echo "3️⃣  Launching Android emulator..."
flutter emulators --launch "$EMULATOR_ID" &
EMULATOR_PID=$!
echo "Emulator starting (PID: $EMULATOR_PID)"
echo "⏳ Waiting for emulator to boot (30 seconds)..."
sleep 30

# Run app
echo ""
echo "4️⃣  Running mobile app..."
cd mobile
flutter run -d android

echo ""
echo "✅ App launched on Android!"
