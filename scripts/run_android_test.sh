#!/bin/bash
# Quick script to test Android app

set -e

echo "🚀 Android Test Run Script"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if backend is running
echo "1. Checking backend..."
if curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is running${NC}"
else
    echo -e "${YELLOW}⚠️  Backend not running. Please start it first:${NC}"
    echo "   cd backend && source .venv/bin/activate"
    echo "   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
    exit 1
fi

# Check Flutter
echo ""
echo "2. Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi
echo -e "${GREEN}✅ Flutter found${NC}"

# Check for devices
echo ""
echo "3. Checking devices..."
DEVICES=$(flutter devices 2>&1 | grep -c "android" || echo "0")
if [ "$DEVICES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No Android device/emulator found${NC}"
    echo ""
    echo "Available emulators:"
    flutter emulators
    echo ""
    echo "Launch an emulator with:"
    echo "  flutter emulators --launch Medium_Phone_API_36.1"
    echo ""
    read -p "Launch emulator now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        flutter emulators --launch Medium_Phone_API_36.1 &
        echo "Waiting for emulator to boot..."
        sleep 10
    else
        echo "Please start an emulator manually and run this script again."
        exit 1
    fi
else
    echo -e "${GREEN}✅ Android device found${NC}"
fi

# Install dependencies
echo ""
echo "4. Installing dependencies..."
cd mobile
flutter pub get > /dev/null 2>&1
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Run app
echo ""
echo "5. Running app..."
echo -e "${GREEN}🚀 Launching app on Android...${NC}"
echo ""
flutter run
