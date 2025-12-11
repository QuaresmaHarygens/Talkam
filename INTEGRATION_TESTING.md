# Integration Testing Guide

Complete guide for testing frontend-backend integration.

## 🧪 Test Checklist

### Authentication Flow

#### 1. User Registration
- [ ] Register new user with phone
- [ ] Register new user with email
- [ ] Register with both phone and email
- [ ] Verify duplicate phone/email handling
- [ ] Test password validation (min 8 chars)

**Test Commands:**
```bash
# Test registration
curl -X POST http://127.0.0.1:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "phone": "+231700000999",
    "password": "TestPass123!",
    "email": "test@example.com"
  }'
```

#### 2. User Login
- [ ] Login with phone and password
- [ ] Verify JWT token returned
- [ ] Test invalid credentials
- [ ] Test token expiration

**Test Commands:**
```bash
# Test login
curl -X POST http://127.0.0.1:8000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+231700000001",
    "password": "AdminPass123!"
  }'
```

#### 3. Password Reset
- [ ] Request password reset with phone
- [ ] Request password reset with email
- [ ] Verify reset token generation
- [ ] Test reset password with token
- [ ] Test expired token handling

**Test Commands:**
```bash
# Request reset
curl -X POST http://127.0.0.1:8000/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"phone": "+231700000001"}'

# Reset password (use token from above)
curl -X POST http://127.0.0.1:8000/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_TOKEN_HERE",
    "new_password": "NewPass123!"
  }'
```

#### 4. Anonymous Mode
- [ ] Start anonymous session
- [ ] Verify anonymous token
- [ ] Test anonymous report creation

### Report Management

#### 5. Create Report
- [ ] Create report with all fields
- [ ] Create report with media
- [ ] Create anonymous report
- [ ] Test location validation
- [ ] Test category validation

**Test Commands:**
```bash
# Create report (replace TOKEN with actual token)
curl -X POST http://127.0.0.1:8000/v1/reports/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "category": "social",
    "severity": "medium",
    "summary": "Test report",
    "details": "Test details",
    "location": {
      "latitude": 6.3153,
      "longitude": -10.8074,
      "county": "Montserrado"
    },
    "anonymous": false
  }'
```

#### 6. Get Report
- [ ] Retrieve report by ID
- [ ] Verify all fields returned
- [ ] Test non-existent report

#### 7. Search Reports
- [ ] Search by county
- [ ] Search by category
- [ ] Search by status
- [ ] Search by text
- [ ] Test combined filters

#### 8. Delete Reports
- [ ] Delete single report (own)
- [ ] Delete all user reports
- [ ] Test unauthorized deletion
- [ ] Verify report removed

**Test Commands:**
```bash
# Delete single report
curl -X DELETE http://127.0.0.1:8000/v1/reports/REPORT_ID \
  -H "Authorization: Bearer TOKEN"

# Delete all reports
curl -X DELETE http://127.0.0.1:8000/v1/reports/ \
  -H "Authorization: Bearer TOKEN"
```

### Media Upload

#### 9. Media Upload Flow
- [ ] Request presigned URL
- [ ] Upload image to S3
- [ ] Upload video to S3
- [ ] Upload audio to S3
- [ ] Verify file size limits (50MB)
- [ ] Test checksum validation

**Test Commands:**
```bash
# Request upload URL
curl -X POST http://127.0.0.1:8000/v1/media/upload \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "key": "test-image.jpg",
    "type": "photo"
  }'

# Upload to S3 (use presigned URL from above)
# This requires multipart form data upload
```

### Mobile App Testing

#### 10. Mobile App Flow
- [ ] Welcome screen → Login
- [ ] Login/Signup tabs
- [ ] Anonymous mode
- [ ] Create report with categories
- [ ] Add media (photo/video/audio)
- [ ] Submit report
- [ ] View report details
- [ ] Delete reports from settings
- [ ] Password reset flow

### Admin Dashboard Testing

#### 11. Admin Features
- [ ] Login as admin
- [ ] View analytics dashboard
- [ ] View reports list
- [ ] Verify reports
- [ ] Export reports

## 🚀 Quick Test Script

```bash
#!/bin/bash
# Quick integration test script

API_URL="http://127.0.0.1:8000/v1"

echo "🧪 Testing Authentication..."
# Test registration
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "phone": "+231700000999",
    "password": "TestPass123!"
  }')

echo "Registration: $REGISTER_RESPONSE"

# Extract token
TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Registration failed"
  exit 1
fi

echo "✅ Registration successful"
echo "Token: ${TOKEN:0:20}..."

echo ""
echo "🧪 Testing Report Creation..."
REPORT_RESPONSE=$(curl -s -X POST "$API_URL/reports/create" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "category": "social",
    "severity": "medium",
    "summary": "Test report",
    "location": {
      "latitude": 6.3153,
      "longitude": -10.8074,
      "county": "Montserrado"
    }
  }')

echo "Report Creation: $REPORT_RESPONSE"
echo "✅ Integration test complete!"
```

## 📱 Mobile App Testing

### Prerequisites
1. Backend API running on port 8000
2. Flutter app dependencies installed
3. Device/emulator connected

### Test Steps

1. **Start Backend:**
   ```bash
   cd backend
   source .venv/bin/activate
   uvicorn app.main:app --reload
   ```

2. **Start Mobile App:**
   ```bash
   cd mobile
   flutter run
   ```

3. **Test Flow:**
   - Open app → Welcome screen
   - Tap "Get started"
   - Test login with: `231770000001` / `AdminPass123!`
   - Test signup with new user
   - Create report with media
   - View report details
   - Test delete reports

## 🔍 Debugging Tips

### Backend Issues
- Check logs: `uvicorn app.main:app --reload --log-level debug`
- Verify database connection
- Check S3/MinIO configuration
- Review API docs: http://127.0.0.1:8000/docs

### Mobile App Issues
- Check Flutter logs: `flutter logs`
- Verify API URL in `providers.dart`
- Test API connectivity: `curl http://127.0.0.1:8000/health`
- Check network permissions

### Media Upload Issues
- Verify S3/MinIO is running
- Check presigned URL expiration
- Verify file size limits
- Check CORS settings

## ✅ Success Criteria

All tests pass when:
- [ ] User can register and login
- [ ] Reports can be created with media
- [ ] Reports can be searched and viewed
- [ ] Reports can be deleted
- [ ] Password reset works
- [ ] Media uploads successfully
- [ ] Mobile app connects to backend
- [ ] Offline queue syncs when online

---

**Ready for comprehensive testing! 🧪**
