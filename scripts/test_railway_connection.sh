#!/bin/bash

# Script to test Railway connection
# Usage: ./scripts/test_railway_connection.sh [URL]
# Example: ./scripts/test_railway_connection.sh https://proactive-celebration-talkam.up.railway.app

set -e

RAILWAY_URL="${1:-https://proactive-celebration-talkam.up.railway.app}"

# Remove trailing slash if present
RAILWAY_URL="${RAILWAY_URL%/}"

echo "🔍 Testing Railway Connection..."
echo "   URL: $RAILWAY_URL"
echo ""

# Test 1: Health endpoint
echo "1️⃣ Testing /v1/health endpoint..."
HEALTH_URL="${RAILWAY_URL}/v1/health"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$HEALTH_URL" 2>&1 || echo "ERROR")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Health check passed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "   ❌ Health check failed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
    echo "   ⚠️  Service might not be deployed or endpoint not found"
else
    echo "   ⚠️  Health check returned HTTP $HTTP_CODE"
    echo "   Response: $BODY"
fi

echo ""

# Test 2: API docs
echo "2️⃣ Testing /docs endpoint..."
DOCS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RAILWAY_URL}/docs" 2>&1 || echo "000")

if [ "$DOCS_CODE" = "200" ]; then
    echo "   ✅ API docs accessible (HTTP $DOCS_CODE)"
    echo "   URL: ${RAILWAY_URL}/docs"
elif [ "$DOCS_CODE" = "404" ]; then
    echo "   ❌ API docs not found (HTTP $DOCS_CODE)"
    echo "   ⚠️  Service might not be deployed"
else
    echo "   ⚠️  API docs returned HTTP $DOCS_CODE"
fi

echo ""

# Test 3: OpenAPI schema
echo "3️⃣ Testing /openapi.json endpoint..."
OPENAPI_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RAILWAY_URL}/openapi.json" 2>&1 || echo "000")

if [ "$OPENAPI_CODE" = "200" ]; then
    echo "   ✅ OpenAPI schema accessible (HTTP $OPENAPI_CODE)"
    echo "   URL: ${RAILWAY_URL}/openapi.json"
elif [ "$OPENAPI_CODE" = "404" ]; then
    echo "   ❌ OpenAPI schema not found (HTTP $OPENAPI_CODE)"
else
    echo "   ⚠️  OpenAPI schema returned HTTP $OPENAPI_CODE"
fi

echo ""

# Test 4: Root endpoint
echo "4️⃣ Testing root endpoint..."
ROOT_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RAILWAY_URL}/" 2>&1 || echo "000")

if [ "$ROOT_CODE" = "200" ] || [ "$ROOT_CODE" = "404" ]; then
    echo "   ✅ Root endpoint accessible (HTTP $ROOT_CODE)"
else
    echo "   ⚠️  Root endpoint returned HTTP $ROOT_CODE"
fi

echo ""

# Summary
echo "📊 Connection Test Summary:"
echo "   Railway URL: $RAILWAY_URL"
echo "   Health endpoint: HTTP $HTTP_CODE"
echo "   API docs: HTTP $DOCS_CODE"
echo "   OpenAPI: HTTP $OPENAPI_CODE"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Service is running and accessible!"
    echo ""
    echo "📱 Next steps:"
    echo "   1. Mobile app is already configured with this URL"
    echo "   2. Rebuild APK: cd mobile && flutter build apk --release"
    echo "   3. Test APK on device"
else
    echo "⚠️  Service is not responding correctly"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "   1. Check Railway dashboard - is service deployed?"
    echo "   2. Check deployment logs for errors"
    echo "   3. Verify environment variables are set"
    echo "   4. Check service is running (not paused)"
fi

