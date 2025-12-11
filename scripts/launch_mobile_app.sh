#!/bin/bash

# Script to launch Talkam Liberia mobile app in full display

echo "🚀 Launching Talkam Liberia Mobile App"
echo "======================================"
echo ""

# Check if backend is running
echo "1️⃣  Checking backend API..."
if curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; then
  echo "✅ Backend API is running"
else
  echo "⚠️  Backend API not running"
  echo ""
  echo "Starting backend in background..."
  cd backend
  source .venv/bin/activate 2>/dev/null || python3 -m venv .venv && source .venv/bin/activate
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 > ../backend.log 2>&1 &
  BACKEND_PID=$!
  echo "Backend started (PID: $BACKEND_PID)"
  echo "Logs: backend.log"
  sleep 3
  cd ..
fi

echo ""
echo "2️⃣  Checking Flutter setup..."
cd mobile

# Check Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found in PATH"
  echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
  exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"

# Get dependencies
echo ""
echo "3️⃣  Installing dependencies..."
flutter pub get

echo ""
echo "4️⃣  Checking for devices..."
DEVICES=$(flutter devices 2>&1 | grep -E "(•|device)" | wc -l)

if [ "$DEVICES" -lt 2 ]; then
  echo "⚠️  No mobile devices/emulators found"
  echo ""
  echo "Available options:"
  echo ""
  echo "📱 iOS Simulator (macOS):"
  echo "   open -a Simulator"
  echo ""
  echo "🤖 Android Emulator:"
  echo "   flutter emulators"
  echo "   flutter emulators --launch <emulator_id>"
  echo ""
  echo "🌐 Web Browser (for quick testing):"
  echo "   flutter run -d chrome"
  echo ""
  read -p "Would you like to open iOS Simulator? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    open -a Simulator
    echo "⏳ Waiting for simulator to start..."
    sleep 10
  fi
fi

echo ""
echo "5️⃣  Available devices:"
flutter devices

echo ""
echo "6️⃣  Launching mobile app..."
echo ""
echo "💡 Tips:"
echo "   - Press 'r' for hot reload"
echo "   - Press 'R' for hot restart"
echo "   - Press 'q' to quit"
echo "   - Cmd+1 (iOS) to see full size"
echo ""

# Try to run on iOS first, then Android, then web
if flutter devices | grep -q "iPhone\|iPad"; then
  echo "📱 Running on iOS Simulator..."
  flutter run -d ios
elif flutter devices | grep -q "android"; then
  echo "🤖 Running on Android Emulator..."
  flutter run -d android
elif flutter devices | grep -q "chrome"; then
  echo "🌐 Running on Chrome (web)..."
  flutter run -d chrome
else
  echo "⚠️  No suitable device found. Starting in web mode..."
  flutter run -d chrome
fi
