#!/bin/bash

# Script to test Render deployment
# Usage: ./scripts/test_render_connection.sh <RENDER_URL>
# Example: ./scripts/test_render_connection.sh https://your-app.onrender.com

set -e

RENDER_URL="$1"

if [ -z "$RENDER_URL" ]; then
    echo "❌ Error: Render URL required"
    echo ""
    echo "Usage: ./scripts/test_render_connection.sh <RENDER_URL>"
    echo "Example: ./scripts/test_render_connection.sh https://your-app.onrender.com"
    exit 1
fi

# Remove trailing slash if present
RENDER_URL="${RENDER_URL%/}"

echo "🔍 Testing Render Deployment..."
echo "   URL: $RENDER_URL"
echo ""

# Test 1: Health endpoint
echo "1️⃣ Testing /v1/health endpoint..."
HEALTH_URL="${RENDER_URL}/v1/health"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$HEALTH_URL" 2>&1 || echo "ERROR")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Health check passed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
    HEALTH_OK=true
elif [ "$HTTP_CODE" = "404" ]; then
    echo "   ❌ Health check failed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
    echo "   ⚠️  Service might not be deployed or endpoint not found"
    HEALTH_OK=false
else
    echo "   ⚠️  Health check returned HTTP $HTTP_CODE"
    echo "   Response: $BODY"
    HEALTH_OK=false
fi

echo ""

# Test 2: API docs
echo "2️⃣ Testing /docs endpoint..."
DOCS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RENDER_URL}/docs" 2>&1 || echo "000")

if [ "$DOCS_CODE" = "200" ]; then
    echo "   ✅ API docs accessible (HTTP $DOCS_CODE)"
    echo "   URL: ${RENDER_URL}/docs"
    DOCS_OK=true
elif [ "$DOCS_CODE" = "404" ]; then
    echo "   ❌ API docs not found (HTTP $DOCS_CODE)"
    DOCS_OK=false
else
    echo "   ⚠️  API docs returned HTTP $DOCS_CODE"
    DOCS_OK=false
fi

echo ""

# Test 3: OpenAPI schema
echo "3️⃣ Testing /openapi.json endpoint..."
OPENAPI_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RENDER_URL}/openapi.json" 2>&1 || echo "000")

if [ "$OPENAPI_CODE" = "200" ]; then
    echo "   ✅ OpenAPI schema accessible (HTTP $OPENAPI_CODE)"
    echo "   URL: ${RENDER_URL}/openapi.json"
    OPENAPI_OK=true
else
    echo "   ⚠️  OpenAPI schema returned HTTP $OPENAPI_CODE"
    OPENAPI_OK=false
fi

echo ""

# Test 4: Root endpoint
echo "4️⃣ Testing root endpoint..."
ROOT_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${RENDER_URL}/" 2>&1 || echo "000")

if [ "$ROOT_CODE" = "200" ] || [ "$ROOT_CODE" = "404" ]; then
    echo "   ✅ Root endpoint accessible (HTTP $ROOT_CODE)"
    ROOT_OK=true
else
    echo "   ⚠️  Root endpoint returned HTTP $ROOT_CODE"
    ROOT_OK=false
fi

echo ""

# Test 5: Database health (if health check passed)
if [ "$HEALTH_OK" = true ]; then
    echo "5️⃣ Testing database connection..."
    DB_HEALTH_URL="${RENDER_URL}/v1/health/db"
    DB_RESPONSE=$(curl -s -w "\n%{http_code}" "$DB_HEALTH_URL" 2>&1 || echo "ERROR")
    DB_CODE=$(echo "$DB_RESPONSE" | tail -n1)
    DB_BODY=$(echo "$DB_RESPONSE" | head -n-1)
    
    if [ "$DB_CODE" = "200" ]; then
        echo "   ✅ Database connection working (HTTP $DB_CODE)"
        echo "   Response: $DB_BODY"
    else
        echo "   ⚠️  Database check returned HTTP $DB_CODE"
        echo "   Response: $DB_BODY"
    fi
    echo ""
fi

# Summary
echo "📊 Connection Test Summary:"
echo "   Render URL: $RENDER_URL"
echo "   Health endpoint: HTTP $HTTP_CODE"
echo "   API docs: HTTP $DOCS_CODE"
echo "   OpenAPI: HTTP $OPENAPI_CODE"
echo "   Root: HTTP $ROOT_CODE"
echo ""

if [ "$HEALTH_OK" = true ]; then
    echo "✅ Service is running and accessible!"
    echo ""
    echo "📱 Next steps:"
    echo "   1. Update mobile app: ./scripts/update_railway_url.sh $RENDER_URL"
    echo "   2. Rebuild APK: cd mobile && flutter build apk --release"
    echo "   3. Test APK on device"
    echo ""
    echo "🔗 Useful URLs:"
    echo "   • Health: ${RENDER_URL}/v1/health"
    echo "   • API Docs: ${RENDER_URL}/docs"
    echo "   • OpenAPI: ${RENDER_URL}/openapi.json"
else
    echo "⚠️  Service is not responding correctly"
    echo ""
    echo "🔍 Troubleshooting:"
    echo "   1. Check Render dashboard - is service deployed?"
    echo "   2. Check deployment logs for errors"
    echo "   3. Verify environment variables are set"
    echo "   4. Check service is running (not sleeping)"
    echo "   5. Wait a few minutes if service just woke up"
fi

