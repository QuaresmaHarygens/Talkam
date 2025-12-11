# Testing Guide - Talkam Liberia

## 🧪 Test Coverage

### Backend Tests

**Test Suites:**
- ✅ `test_attestations.py` - Community attestation system
- ✅ `test_analytics.py` - Enhanced analytics endpoints
- ✅ `test_search.py` - Advanced search features
- ✅ `test_priority.py` - Priority scoring system
- ✅ `test_reports.py` - Report management
- ✅ `test_integration.py` - Integration tests
- ✅ `test_auth.py` - Authentication
- ✅ `test_dashboards.py` - Dashboard endpoints

**Test Results:**
- **17/17 core tests passing** ✅
- **23/24 total tests passing** (1 test requires real DB for notifications)

### Running Tests

#### Unit Tests
```bash
cd backend
source .venv/bin/activate
export PYTHONPATH="$(pwd)"
pytest tests/ -v
```

#### Specific Test Suites
```bash
# Test attestations
pytest tests/test_attestations.py -v

# Test analytics
pytest tests/test_analytics.py -v

# Test search
pytest tests/test_search.py -v

# Test priority scoring
pytest tests/test_priority.py -v
```

#### Integration Tests
```bash
# Test against real API (requires server running)
./scripts/test_api.sh
```

## 📋 Manual Testing Checklist

### 1. Community Attestation Flow

**Setup:**
1. Create two test users (User A and User B)
2. Ensure both are in the same county

**Test Steps:**
- [ ] User A creates a report
- [ ] User B receives notification
- [ ] User B can view notification in app
- [ ] User B can attest (confirm/deny/needs_info)
- [ ] Report witness count updates
- [ ] Priority score recalculates

**API Test:**
```bash
# As User A: Create report
curl -X POST http://127.0.0.1:8000/v1/reports/create \
  -H "Authorization: Bearer <user_a_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "category": "infrastructure",
    "severity": "high",
    "summary": "Test report",
    "location": {"latitude": 6.4281, "longitude": -10.7619, "county": "Montserrado"}
  }'

# As User B: Check notifications
curl http://127.0.0.1:8000/v1/notifications \
  -H "Authorization: Bearer <user_b_token>"

# As User B: Attest
curl -X POST http://127.0.0.1:8000/v1/attestations/reports/<report_id>/attest \
  -H "Authorization: Bearer <user_b_token>" \
  -H "Content-Type: application/json" \
  -d '{"action": "confirm", "confidence": "high"}'
```

### 2. Advanced Search

**Test Filters:**
- [ ] Category filter
- [ ] Severity filter
- [ ] Status filter
- [ ] Priority filter (min_priority)
- [ ] Date range (date_from, date_to)
- [ ] Agency filter (assigned_agency)
- [ ] Full-text search (text)
- [ ] Sorting (sort_by, sort_order)
- [ ] Pagination (page, page_size)

**Test:**
```bash
# Multiple filters
curl "http://127.0.0.1:8000/v1/reports/search?category=infrastructure&severity=high&min_priority=0.7&sort_by=priority_score&sort_order=desc" \
  -H "Authorization: Bearer <token>"

# Date range
curl "http://127.0.0.1:8000/v1/reports/search?date_from=2025-12-01T00:00:00Z&date_to=2025-12-08T23:59:59Z" \
  -H "Authorization: Bearer <token>"
```

### 3. Analytics

**Test Endpoints:**
- [ ] Analytics dashboard
- [ ] Geographic heatmap
- [ ] Category insights
- [ ] Time series

**Test:**
```bash
# Analytics dashboard
curl http://127.0.0.1:8000/v1/dashboards/analytics \
  -H "Authorization: Bearer <admin_token>"

# Heatmap
curl http://127.0.0.1:8000/v1/dashboards/heatmap?days=30 \
  -H "Authorization: Bearer <admin_token>"

# Category insights
curl http://127.0.0.1:8000/v1/dashboards/category-insights \
  -H "Authorization: Bearer <admin_token>"
```

### 4. Priority Scoring

**Test:**
- [ ] Priority calculated on report creation
- [ ] Priority updates on attestation
- [ ] Priority updates on verification
- [ ] Priority filter works in search
- [ ] Priority sorting works

**Verify:**
```bash
# Create report and check priority_score
curl -X POST http://127.0.0.1:8000/v1/reports/create \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{...}'
# Check response includes "priority_score"

# Search by priority
curl "http://127.0.0.1:8000/v1/reports/search?min_priority=0.7" \
  -H "Authorization: Bearer <token>"
```

### 5. Enhanced Verification

**Test:**
- [ ] NGO verification updates status
- [ ] Community attestation updates status
- [ ] Combined consensus works
- [ ] Multi-verifier threshold met

**Test:**
```bash
# NGO verifies
curl -X POST http://127.0.0.1:8000/v1/reports/<id>/verify \
  -H "Authorization: Bearer <ngo_token>" \
  -d '{"action": "confirm"}'

# Community attests
curl -X POST http://127.0.0.1:8000/v1/attestations/reports/<id>/attest \
  -H "Authorization: Bearer <user_token>" \
  -d '{"action": "confirm", "confidence": "high"}'

# Check report status updated
curl http://127.0.0.1:8000/v1/reports/<id> \
  -H "Authorization: Bearer <token>"
```

## 🎯 Test Scenarios

### Scenario 1: High-Priority Report Flow

1. **Create Critical Report**
   - Category: security
   - Severity: critical
   - Location: Montserrado

2. **Verify Priority**
   - Check priority_score > 0.7
   - Should appear in high-priority search

3. **Community Response**
   - 3+ users attest (confirm)
   - Priority increases
   - Status may auto-verify

### Scenario 2: Search and Filter

1. **Create Multiple Reports**
   - Different categories
   - Different severities
   - Different dates

2. **Test Filters**
   - Filter by category
   - Filter by severity
   - Filter by date range
   - Filter by priority

3. **Test Sorting**
   - Sort by priority (desc)
   - Sort by date (asc)
   - Sort by severity

### Scenario 3: Analytics Dashboard

1. **Generate Data**
   - Create reports in different counties
   - Create reports in different categories
   - Create reports over time

2. **View Analytics**
   - Check KPIs
   - Check county breakdown
   - Check category trends
   - Check heatmap
   - Check time series

## 🐛 Known Test Limitations

1. **FakeSession Limitations**
   - Complex queries may not work perfectly
   - Some relationship loading may fail
   - Notification queries need real DB

2. **Background Tasks**
   - Notification sending is async
   - May not be visible in unit tests
   - Test with real API for full flow

3. **Database State**
   - Tests may affect each other
   - Use transaction rollback in production tests
   - Seed data may interfere

## 📊 Test Coverage Goals

- **Unit Tests**: 80%+ coverage
- **Integration Tests**: All endpoints covered
- **E2E Tests**: Critical flows covered

## 🚀 Continuous Testing

**Pre-commit:**
```bash
pytest tests/ -v --tb=short
```

**CI/CD:**
```bash
pytest tests/ --cov=app --cov-report=html
```

**Production Smoke Tests:**
```bash
./scripts/test_api.sh
```

---

**Status**: ✅ Comprehensive test suite in place!
