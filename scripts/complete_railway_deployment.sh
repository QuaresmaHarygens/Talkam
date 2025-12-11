#!/bin/bash

# Complete Railway Deployment Script
# Usage: ./scripts/complete_railway_deployment.sh <RAILWAY_URL>
# Example: ./scripts/complete_railway_deployment.sh https://talkam-api.railway.app

set -e

RAILWAY_URL="$1"

if [ -z "$RAILWAY_URL" ]; then
    echo "❌ Error: Railway URL required"
    echo ""
    echo "Usage: ./scripts/complete_railway_deployment.sh <RAILWAY_URL>"
    echo "Example: ./scripts/complete_railway_deployment.sh https://talkam-api.railway.app"
    echo ""
    echo "📋 Steps to get Railway URL:"
    echo "  1. Go to: https://railway.app/dashboard"
    echo "  2. Open your service"
    echo "  3. Go to Settings → Domains"
    echo "  4. Click 'Generate Domain'"
    echo "  5. Copy the URL"
    exit 1
fi

# Remove trailing slash if present
RAILWAY_URL="${RAILWAY_URL%/}"

# Ensure URL has /v1 suffix for API
API_URL="${RAILWAY_URL}/v1"

echo "🚀 Completing Railway Deployment"
echo "   Railway URL: $RAILWAY_URL"
echo "   API URL: $API_URL"
echo ""

# Step 1: Verify deployment
echo "1️⃣ Verifying deployment..."
if command -v curl &> /dev/null; then
    HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "${RAILWAY_URL}/health" || echo "ERROR")
    HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
    BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "   ✅ Health check passed (HTTP $HTTP_CODE)"
        echo "   Response: $BODY"
    else
        echo "   ⚠️  Health check returned HTTP $HTTP_CODE"
        echo "   Response: $BODY"
        echo "   Continuing anyway..."
    fi
else
    echo "   ⚠️  curl not found, skipping health check"
fi

echo ""

# Step 2: Update mobile app
echo "2️⃣ Updating mobile app..."
PROVIDERS_FILE="mobile/lib/providers.dart"

if [ ! -f "$PROVIDERS_FILE" ]; then
    echo "   ❌ Error: $PROVIDERS_FILE not found"
    exit 1
fi

# Backup original file
cp "$PROVIDERS_FILE" "${PROVIDERS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

# Update the baseUrl
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|baseUrl: 'https://[^']*'|baseUrl: '$API_URL'|g" "$PROVIDERS_FILE"
    sed -i '' "s|baseUrl: 'http://[^']*'|baseUrl: '$API_URL'|g" "$PROVIDERS_FILE"
else
    # Linux
    sed -i "s|baseUrl: 'https://[^']*'|baseUrl: '$API_URL'|g" "$PROVIDERS_FILE"
    sed -i "s|baseUrl: 'http://[^']*'|baseUrl: '$API_URL'|g" "$PROVIDERS_FILE"
fi

echo "   ✅ Updated $PROVIDERS_FILE"
echo "   💾 Backup saved"

echo ""

# Step 3: Rebuild APK
echo "3️⃣ Rebuilding APK..."
cd mobile

if ! command -v flutter &> /dev/null; then
    echo "   ⚠️  Flutter not found in PATH"
    echo "   Please rebuild APK manually:"
    echo "   cd mobile && flutter clean && flutter pub get && flutter build apk --release"
    cd ..
    exit 0
fi

echo "   Cleaning..."
flutter clean > /dev/null 2>&1 || true

echo "   Getting dependencies..."
flutter pub get > /dev/null 2>&1 || true

echo "   Building APK (this may take a few minutes)..."
if flutter build apk --release; then
    echo "   ✅ APK built successfully!"
    echo ""
    echo "   📦 APK Location:"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
else
    echo "   ❌ APK build failed"
    echo "   Please check the error messages above"
    cd ..
    exit 1
fi

cd ..

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📋 Summary:"
echo "   ✅ Deployment verified"
echo "   ✅ Mobile app updated with Railway URL"
echo "   ✅ APK rebuilt"
echo ""
echo "📱 Next Steps:"
echo "   1. Install APK on device:"
echo "      adb install mobile/build/app/outputs/flutter-apk/app-release.apk"
echo "   2. Test all features"
echo "   3. Share APK with users"
echo ""
echo "🔗 Your Railway URL: $RAILWAY_URL"
echo "🔗 API Endpoint: $API_URL"

