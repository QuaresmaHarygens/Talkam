#!/bin/bash
# Test script for new features

set -e

API_URL="${API_URL:-http://127.0.0.1:8000}"
BASE_URL="${BASE_URL:-$API_URL/v1}"

echo "🧪 Testing New Features"
echo "API URL: $BASE_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get auth token (assumes anonymous auth works)
echo "1. Getting authentication token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/anonymous-start" \
  -H "Content-Type: application/json" \
  -d '{"device_hash": "test-device-'$(date +%s)'", "county": "Montserrado"}')

TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null || echo "")

if [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ Failed to get token${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Token obtained${NC}"
echo ""

# Test device token registration
echo "2. Testing Device Token Registration..."
REGISTER_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/device-tokens/register" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "test_fcm_token_'$(date +%s)'",
    "platform": "android",
    "app_version": "1.0.0",
    "device_info": "Test Device"
  }')

HTTP_CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
BODY=$(echo "$REGISTER_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✅ Device token registered${NC}"
    TOKEN_ID=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null || echo "")
else
    echo -e "${RED}❌ Failed to register token (HTTP $HTTP_CODE)${NC}"
    echo "$BODY"
fi
echo ""

# Test list device tokens
echo "3. Testing List Device Tokens..."
LIST_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/device-tokens" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$LIST_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Device tokens listed${NC}"
else
    echo -e "${RED}❌ Failed to list tokens (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# Test analytics endpoints
echo "4. Testing Analytics Endpoints..."
ANALYTICS_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/dashboards/analytics" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$ANALYTICS_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Analytics dashboard accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Analytics requires admin role (HTTP $HTTP_CODE)${NC}"
fi

HEATMAP_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/dashboards/heatmap?days=30" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$HEATMAP_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Heatmap endpoint accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Heatmap requires admin role (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# Test advanced search
echo "5. Testing Advanced Search..."
SEARCH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/reports/search?category=infrastructure&severity=high&sort_by=priority_score&sort_order=desc" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$SEARCH_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Advanced search working${NC}"
else
    echo -e "${RED}❌ Search failed (HTTP $HTTP_CODE)${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Testing complete!${NC}"
echo ""
echo "Note: Some endpoints may require admin role for full access."
