#!/bin/bash

# Test script to verify error fixes are working
# Usage: ./scripts/test_fixes.sh

BASE_URL="https://little-amity-talkam-c84a1504.koyeb.app"
API_URL="${BASE_URL}/v1"

echo "🧪 Testing Error Fixes..."
echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "${BASE_URL}/health")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ Health check passed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
else
    echo "❌ Health check failed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
fi
echo ""

# Test 2: API Health
echo "2️⃣ Testing API Health Endpoint..."
API_HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "${API_URL}/health")
API_HTTP_CODE=$(echo "$API_HEALTH_RESPONSE" | tail -n1)
API_BODY=$(echo "$API_HEALTH_RESPONSE" | head -n-1)

if [ "$API_HTTP_CODE" -eq 200 ]; then
    echo "✅ API health check passed (HTTP $API_HTTP_CODE)"
    echo "   Response: $API_BODY"
else
    echo "❌ API health check failed (HTTP $API_HTTP_CODE)"
    echo "   Response: $API_BODY"
fi
echo ""

# Test 3: Reports Search (should return 200 or 401, not 500)
echo "3️⃣ Testing Reports Search Endpoint..."
SEARCH_RESPONSE=$(curl -s -w "\n%{http_code}" "${API_URL}/reports/search")
SEARCH_HTTP_CODE=$(echo "$SEARCH_RESPONSE" | tail -n1)
SEARCH_BODY=$(echo "$SEARCH_RESPONSE" | head -n-1)

if [ "$SEARCH_HTTP_CODE" -eq 200 ]; then
    echo "✅ Reports search passed (HTTP $SEARCH_HTTP_CODE)"
    echo "   Response: $SEARCH_BODY" | head -c 200
    echo "..."
elif [ "$SEARCH_HTTP_CODE" -eq 401 ]; then
    echo "⚠️  Reports search requires authentication (HTTP $SEARCH_HTTP_CODE)"
    echo "   This is expected - endpoint exists and is working"
else
    echo "❌ Reports search failed (HTTP $SEARCH_HTTP_CODE)"
    echo "   Response: $SEARCH_BODY"
fi
echo ""

# Test 4: Media Upload (should return 401 or 503, not 500)
echo "4️⃣ Testing Media Upload Endpoint..."
UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/media/upload" \
  -H "Content-Type: application/json" \
  -d '{"type": "photo"}')
UPLOAD_HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
UPLOAD_BODY=$(echo "$UPLOAD_RESPONSE" | head -n-1)

if [ "$UPLOAD_HTTP_CODE" -eq 401 ]; then
    echo "✅ Media upload endpoint exists (HTTP $UPLOAD_HTTP_CODE - auth required)"
    echo "   This is expected - endpoint exists and requires authentication"
elif [ "$UPLOAD_HTTP_CODE" -eq 503 ]; then
    echo "⚠️  Media upload returns 503 (S3 not configured)"
    echo "   Response: $UPLOAD_BODY"
    echo "   This is expected if S3 is not configured"
elif [ "$UPLOAD_HTTP_CODE" -eq 500 ]; then
    echo "❌ Media upload still returns 500 error!"
    echo "   Response: $UPLOAD_BODY"
    echo "   Fix may not be deployed yet"
else
    echo "⚠️  Media upload returned HTTP $UPLOAD_HTTP_CODE"
    echo "   Response: $UPLOAD_BODY"
fi
echo ""

echo "📊 Summary:"
echo "   Health: $([ "$HTTP_CODE" -eq 200 ] && echo "✅" || echo "❌")"
echo "   API Health: $([ "$API_HTTP_CODE" -eq 200 ] && echo "✅" || echo "❌")"
echo "   Reports Search: $([ "$SEARCH_HTTP_CODE" -eq 200 ] || [ "$SEARCH_HTTP_CODE" -eq 401 ] && echo "✅" || echo "❌")"
echo "   Media Upload: $([ "$UPLOAD_HTTP_CODE" -ne 500 ] && echo "✅" || echo "❌")"
echo ""
echo "✅ = Working correctly"
echo "⚠️  = Expected behavior (auth required or service unavailable)"
echo "❌ = Error - needs investigation"
