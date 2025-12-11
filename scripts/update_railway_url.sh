#!/bin/bash

# Script to update mobile app with Railway deployment URL
# Usage: ./scripts/update_railway_url.sh <RAILWAY_URL>
# Example: ./scripts/update_railway_url.sh https://talkam-api.railway.app

set -e

RAILWAY_URL="$1"

if [ -z "$RAILWAY_URL" ]; then
    echo "❌ Error: Railway URL required"
    echo ""
    echo "Usage: ./scripts/update_railway_url.sh <RAILWAY_URL>"
    echo "Example: ./scripts/update_railway_url.sh https://talkam-api.railway.app"
    exit 1
fi

# Remove trailing slash if present
RAILWAY_URL="${RAILWAY_URL%/}"

# Ensure URL has /v1 suffix
if [[ ! "$RAILWAY_URL" == */v1 ]]; then
    RAILWAY_URL="${RAILWAY_URL}/v1"
fi

PROVIDERS_FILE="mobile/lib/providers.dart"

if [ ! -f "$PROVIDERS_FILE" ]; then
    echo "❌ Error: $PROVIDERS_FILE not found"
    exit 1
fi

echo "🔄 Updating mobile app with Railway URL..."
echo "   URL: $RAILWAY_URL"
echo ""

# Backup original file
cp "$PROVIDERS_FILE" "${PROVIDERS_FILE}.backup"

# Update the baseUrl in providers.dart
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|baseUrl: 'https://[^']*'|baseUrl: '$RAILWAY_URL'|g" "$PROVIDERS_FILE"
else
    # Linux
    sed -i "s|baseUrl: 'https://[^']*'|baseUrl: '$RAILWAY_URL'|g" "$PROVIDERS_FILE"
fi

echo "✅ Updated $PROVIDERS_FILE"
echo ""
echo "📱 Next steps:"
echo "   1. Rebuild APK: cd mobile && flutter build apk --release"
echo "   2. APK location: mobile/build/app/outputs/flutter-apk/app-release.apk"
echo "   3. Share APK with users"
echo ""
echo "💾 Backup saved: ${PROVIDERS_FILE}.backup"





