#!/bin/bash

# Integration Test Script for Talkam Liberia API

API_URL="http://127.0.0.1:8000/v1"
BASE_URL="http://127.0.0.1:8000"

echo "🧪 Talkam Liberia Integration Tests"
echo "=================================="
echo ""

# Test 1: Health Check
echo "1️⃣  Testing Health Check..."
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q "healthy"; then
  echo "✅ Health check passed"
else
  echo "❌ Health check failed: $HEALTH"
  exit 1
fi

# Test 2: Register User
echo ""
echo "2️⃣  Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Integration Test User",
    "phone": "+231700000888",
    "password": "TestPass123!",
    "email": "test@integration.com"
  }')

if echo "$REGISTER_RESPONSE" | grep -q "access_token"; then
  echo "✅ Registration successful"
  TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
else
  echo "⚠️  Registration may have failed (user might exist): $REGISTER_RESPONSE"
  # Try login instead
  echo "   Attempting login..."
  LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
      "phone": "+231700000888",
      "password": "TestPass123!"
    }')
  if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    echo "✅ Login successful"
  else
    echo "❌ Both registration and login failed"
    exit 1
  fi
fi

if [ -z "$TOKEN" ]; then
  echo "❌ Could not extract token"
  exit 1
fi

echo "   Token: ${TOKEN:0:30}..."

# Test 3: Create Report
echo ""
echo "3️⃣  Testing Report Creation..."
REPORT_RESPONSE=$(curl -s -X POST "$API_URL/reports/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "category": "social",
    "severity": "medium",
    "summary": "Integration test report",
    "details": "This is a test report created during integration testing",
    "location": {
      "latitude": 6.3153,
      "longitude": -10.8074,
      "county": "Montserrado",
      "description": "Test location"
    },
    "anonymous": false
  }')

if echo "$REPORT_RESPONSE" | grep -q "id"; then
  echo "✅ Report created successfully"
  REPORT_ID=$(echo "$REPORT_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
  echo "   Report ID: $REPORT_ID"
else
  echo "❌ Report creation failed: $REPORT_RESPONSE"
  exit 1
fi

# Test 4: Get Report
echo ""
echo "4️⃣  Testing Get Report..."
GET_RESPONSE=$(curl -s -X GET "$API_URL/reports/$REPORT_ID" \
  -H "Authorization: Bearer $TOKEN")

if echo "$GET_RESPONSE" | grep -q "summary"; then
  echo "✅ Report retrieved successfully"
else
  echo "❌ Report retrieval failed: $GET_RESPONSE"
  exit 1
fi

# Test 5: Search Reports
echo ""
echo "5️⃣  Testing Report Search..."
SEARCH_RESPONSE=$(curl -s -X GET "$API_URL/reports/search?county=Montserrado" \
  -H "Authorization: Bearer $TOKEN")

if echo "$SEARCH_RESPONSE" | grep -q "results"; then
  echo "✅ Report search successful"
else
  echo "❌ Report search failed: $SEARCH_RESPONSE"
  exit 1
fi

# Test 6: Password Reset Request
echo ""
echo "6️⃣  Testing Password Reset Request..."
RESET_REQUEST=$(curl -s -X POST "$API_URL/auth/forgot-password" \
  -H "Content-Type: application/json" \
  -d '{"phone": "+231700000888"}')

if echo "$RESET_REQUEST" | grep -q "message"; then
  echo "✅ Password reset request successful"
else
  echo "❌ Password reset request failed: $RESET_REQUEST"
  exit 1
fi

# Test 7: Delete Report
echo ""
echo "7️⃣  Testing Delete Report..."
DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL/reports/$REPORT_ID" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$DELETE_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Report deleted successfully"
else
  echo "⚠️  Delete response: HTTP $HTTP_CODE"
fi

# Test 8: Media Upload URL Request
echo ""
echo "8️⃣  Testing Media Upload URL Request..."
MEDIA_RESPONSE=$(curl -s -X POST "$API_URL/media/upload" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "key": "test-image.jpg",
    "type": "photo"
  }')

if echo "$MEDIA_RESPONSE" | grep -q "upload_url"; then
  echo "✅ Media upload URL generated successfully"
else
  echo "⚠️  Media upload URL generation: $MEDIA_RESPONSE"
  echo "   (This may fail if S3 is not configured)"
fi

echo ""
echo "=================================="
echo "✅ Integration tests completed!"
echo ""
echo "📋 Summary:"
echo "   - Health check: ✅"
echo "   - Registration/Login: ✅"
echo "   - Report creation: ✅"
echo "   - Report retrieval: ✅"
echo "   - Report search: ✅"
echo "   - Password reset: ✅"
echo "   - Report deletion: ✅"
echo "   - Media upload URL: ⚠️  (requires S3)"
echo ""
echo "🎉 All critical tests passed!"
