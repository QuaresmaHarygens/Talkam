#!/bin/bash

# Script to verify Railway deployment
# Usage: ./scripts/verify_railway_deployment.sh <RAILWAY_URL>
# Example: ./scripts/verify_railway_deployment.sh https://talkam-api.railway.app

set -e

RAILWAY_URL="$1"

if [ -z "$RAILWAY_URL" ]; then
    echo "❌ Error: Railway URL required"
    echo ""
    echo "Usage: ./scripts/verify_railway_deployment.sh <RAILWAY_URL>"
    echo "Example: ./scripts/verify_railway_deployment.sh https://talkam-api.railway.app"
    exit 1
fi

# Remove trailing slash if present
RAILWAY_URL="${RAILWAY_URL%/}"

echo "🔍 Verifying Railway deployment..."
echo "   URL: $RAILWAY_URL"
echo ""

# Test health endpoint
HEALTH_URL="${RAILWAY_URL}/health"
echo "1️⃣ Testing health endpoint: $HEALTH_URL"

if command -v curl &> /dev/null; then
    HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$HEALTH_URL" || echo "ERROR")
    HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
    BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "   ✅ Health check passed (HTTP $HTTP_CODE)"
        echo "   Response: $BODY"
    else
        echo "   ❌ Health check failed (HTTP $HTTP_CODE)"
        echo "   Response: $BODY"
        exit 1
    fi
else
    echo "   ⚠️  curl not found, skipping health check"
fi

echo ""

# Test API docs
DOCS_URL="${RAILWAY_URL}/docs"
echo "2️⃣ Testing API docs: $DOCS_URL"

if command -v curl &> /dev/null; then
    DOCS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DOCS_URL" || echo "000")
    
    if [ "$DOCS_CODE" = "200" ]; then
        echo "   ✅ API docs accessible (HTTP $DOCS_CODE)"
    else
        echo "   ⚠️  API docs returned HTTP $DOCS_CODE"
    fi
else
    echo "   ⚠️  curl not found, skipping docs check"
fi

echo ""

# Test OpenAPI schema
OPENAPI_URL="${RAILWAY_URL}/openapi.json"
echo "3️⃣ Testing OpenAPI schema: $OPENAPI_URL"

if command -v curl &> /dev/null; then
    OPENAPI_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$OPENAPI_URL" || echo "000")
    
    if [ "$OPENAPI_CODE" = "200" ]; then
        echo "   ✅ OpenAPI schema accessible (HTTP $OPENAPI_CODE)"
    else
        echo "   ⚠️  OpenAPI schema returned HTTP $OPENAPI_CODE"
    fi
else
    echo "   ⚠️  curl not found, skipping OpenAPI check"
fi

echo ""
echo "✅ Deployment verification complete!"
echo ""
echo "📱 Next steps:"
echo "   1. Update app: ./scripts/update_railway_url.sh $RAILWAY_URL"
echo "   2. Rebuild APK: cd mobile && flutter build apk --release"
echo "   3. Test APK on device"
echo "   4. Share APK with users"



