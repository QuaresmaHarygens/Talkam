#!/bin/bash
# API Testing Script
# Tests the running API server against real endpoints

set -e

API_URL="${API_URL:-http://127.0.0.1:8000}"
BASE_URL="${BASE_URL:-$API_URL/v1}"

echo "🧪 Testing Talkam Liberia API"
echo "API URL: $BASE_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    if [ -z "$expected_status" ]; then
        expected_status=200
    fi
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint" \
            ${TOKEN:+-H "Authorization: Bearer $TOKEN"})
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            ${TOKEN:+-H "Authorization: Bearer $TOKEN"} \
            ${data:+-d "$data"})
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅${NC} $description"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌${NC} $description (Expected $expected_status, got $http_code)"
        echo "   Response: $body" | head -c 200
        echo ""
        ((FAILED++))
        return 1
    fi
}

# Health check
echo "1. Health Check"
test_endpoint "GET" "/health" "" 200 "Health check"
echo ""

# Anonymous auth
echo "2. Authentication"
ANON_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/anonymous-start" \
    -H "Content-Type: application/json" \
    -d '{"device_hash": "test-device-'$(date +%s)'", "county": "Montserrado"}')
TOKEN=$(echo "$ANON_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('token', ''))" 2>/dev/null || echo "")

if [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅${NC} Anonymous authentication"
    ((PASSED++))
else
    echo -e "${RED}❌${NC} Anonymous authentication failed"
    ((FAILED++))
fi
echo ""

# Create report
echo "3. Report Creation"
REPORT_DATA='{
    "category": "infrastructure",
    "severity": "high",
    "summary": "Test report for API testing",
    "details": "This is a test report created during API testing",
    "location": {
        "latitude": 6.4281,
        "longitude": -10.7619,
        "county": "Montserrado"
    },
    "anonymous": false
}'

REPORT_RESPONSE=$(curl -s -X POST "$BASE_URL/reports/create" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "$REPORT_DATA")

REPORT_ID=$(echo "$REPORT_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))" 2>/dev/null || echo "")

if [ -n "$REPORT_ID" ]; then
    echo -e "${GREEN}✅${NC} Report created: $REPORT_ID"
    ((PASSED++))
else
    echo -e "${RED}❌${NC} Report creation failed"
    ((FAILED++))
fi
echo ""

# Search reports
echo "4. Search & Filtering"
test_endpoint "GET" "/reports/search?category=infrastructure" "" 200 "Search by category"
test_endpoint "GET" "/reports/search?severity=high" "" 200 "Search by severity"
test_endpoint "GET" "/reports/search?min_priority=0.5" "" 200 "Search by priority"
test_endpoint "GET" "/reports/search?sort_by=priority_score&sort_order=desc" "" 200 "Search with sorting"
echo ""

# Analytics
echo "5. Analytics Endpoints"
test_endpoint "GET" "/dashboards/analytics" "" 200 "Analytics dashboard"
test_endpoint "GET" "/dashboards/heatmap?days=30" "" 200 "Geographic heatmap"
test_endpoint "GET" "/dashboards/category-insights" "" 200 "Category insights"
test_endpoint "GET" "/dashboards/time-series?days=30&group_by=day" "" 200 "Time series"
echo ""

# Notifications
echo "6. Notifications"
test_endpoint "GET" "/notifications" "" 200 "Get notifications"
test_endpoint "GET" "/notifications/unread/count" "" 200 "Get unread count"
echo ""

# Attestations (if report was created)
if [ -n "$REPORT_ID" ]; then
    echo "7. Attestations"
    ATTEST_DATA='{
        "action": "confirm",
        "confidence": "high",
        "comment": "I can confirm this report"
    }'
    test_endpoint "POST" "/attestations/reports/$REPORT_ID/attest" "$ATTEST_DATA" 201 "Attest to report"
    echo ""
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary:"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Failed: $FAILED${NC}"
    exit 0
fi
