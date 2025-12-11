#!/bin/bash
# Script to clean caches and build APK

set -e

echo "🧹 Cleaning up to free disk space..."
echo ""

# Stop Gradle daemons
echo "1. Stopping Gradle daemons..."
pkill -f gradle || true

# Clean Gradle cache
echo "2. Cleaning Gradle cache (~2.7GB)..."
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon
echo "✅ Gradle cache cleaned"

# Clean Flutter build
echo "3. Cleaning Flutter build..."
cd "/Users/visionalventure/Watch Liberia/mobile"
flutter clean
rm -rf build
rm -rf .dart_tool
rm -rf android/.gradle
rm -rf android/build
rm -rf android/app/build
echo "✅ Flutter build cleaned"

# Check disk space
echo ""
echo "📊 Disk space after cleanup:"
df -h / | tail -1

# Get dependencies
echo ""
echo "4. Getting dependencies..."
flutter pub get

# Build APK
echo ""
echo "5. Building release APK..."
echo "   This may take 5-10 minutes..."
flutter build apk --release

# Show result
echo ""
echo "✅ APK built successfully!"
echo ""
echo "📱 APK Location:"
echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📦 File size:"
ls -lh build/app/outputs/flutter-apk/app-release.apk

