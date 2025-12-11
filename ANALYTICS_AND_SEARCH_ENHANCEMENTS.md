# Analytics and Search Enhancements

## ✅ Completed Enhancements

### 1. Enhanced Analytics

#### New Endpoints

**Geographic Heatmap**
```
GET /v1/dashboards/heatmap?days=30
```
Returns heatmap data with:
- Latitude/longitude coordinates
- Report counts per location
- Average severity
- Intensity scores (0-1)

**Category Insights**
```
GET /v1/dashboards/category-insights
```
Returns detailed insights:
- Reports by category
- Verification rates per category
- Average severity by category
- AI scores by category
- Most reported category
- Most verified category

**Time Series Data**
```
GET /v1/dashboards/time-series?days=30&group_by=day
```
Returns time-based trends:
- Reports over time (grouped by day/week/month)
- Verified reports over time
- Useful for trend analysis

### 2. Advanced Search

Enhanced `/v1/reports/search` endpoint with:

**New Filters:**
- `assigned_agency` - Filter by assigned agency/NGO
- `min_priority` - Filter by minimum priority score (0.0-1.0)
- `date_from` - Filter reports from date (ISO 8601)
- `date_to` - Filter reports to date (ISO 8601)

**New Sorting:**
- `sort_by` - Sort by: `created_at`, `severity`, `priority_score`, `updated_at`
- `sort_order` - Sort order: `asc` or `desc`

**Enhanced Text Search:**
- Now searches both `summary` and `details` fields
- Case-insensitive partial matching

### 3. Push Notification Service

**Service Created:**
- `PushNotificationService` class for FCM/APNs integration
- Integrated into community notification flow
- Ready for production FCM/APNs setup

**Features:**
- Send to specific user
- Send to device tokens
- Attestation request notifications
- Delivery statistics

## Usage Examples

### Analytics

**Get Heatmap Data:**
```bash
curl http://127.0.0.1:8000/v1/dashboards/heatmap?days=30 \
  -H "Authorization: Bearer <token>"
```

**Get Category Insights:**
```bash
curl http://127.0.0.1:8000/v1/dashboards/category-insights \
  -H "Authorization: Bearer <token>"
```

**Get Time Series:**
```bash
curl http://127.0.0.1:8000/v1/dashboards/time-series?days=90&group_by=week \
  -H "Authorization: Bearer <token>"
```

### Advanced Search

**Search with Multiple Filters:**
```bash
curl "http://127.0.0.1:8000/v1/reports/search?category=infrastructure&severity=high&min_priority=0.7&sort_by=priority_score&sort_order=desc" \
  -H "Authorization: Bearer <token>"
```

**Date Range Search:**
```bash
curl "http://127.0.0.1:8000/v1/reports/search?date_from=2025-12-01T00:00:00Z&date_to=2025-12-08T23:59:59Z" \
  -H "Authorization: Bearer <token>"
```

**Full-Text Search:**
```bash
curl "http://127.0.0.1:8000/v1/reports/search?text=road+blockage" \
  -H "Authorization: Bearer <token>"
```

## Mobile App Integration

### Update API Client

Add to `mobile/lib/api/client.dart`:

```dart
// Analytics endpoints
Future<Map<String, dynamic>> getHeatmap({int days = 30}) async {
  final response = await _dio.get('/dashboards/heatmap', queryParameters: {
    'days': days,
  });
  return response.data;
}

Future<Map<String, dynamic>> getCategoryInsights() async {
  final response = await _dio.get('/dashboards/category-insights');
  return response.data;
}

Future<Map<String, dynamic>> getTimeSeries({
  int days = 30,
  String groupBy = 'day',
}) async {
  final response = await _dio.get('/dashboards/time-series', queryParameters: {
    'days': days,
    'group_by': groupBy,
  });
  return response.data;
}

// Enhanced search
Future<Map<String, dynamic>> searchReports({
  // ... existing parameters ...
  String? assignedAgency,
  double? minPriority,
  String? dateFrom,
  String? dateTo,
  String sortBy = 'created_at',
  String sortOrder = 'desc',
}) async {
  final response = await _dio.get('/reports/search', queryParameters: {
    // ... existing parameters ...
    if (assignedAgency != null) 'assigned_agency': assignedAgency,
    if (minPriority != null) 'min_priority': minPriority,
    if (dateFrom != null) 'date_from': dateFrom,
    if (dateTo != null) 'date_to': dateTo,
    'sort_by': sortBy,
    'sort_order': sortOrder,
  });
  return response.data;
}
```

## Production Setup for Push Notifications

### Firebase Cloud Messaging (FCM)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com
   - Create new project
   - Enable Cloud Messaging

2. **Get Server Key**
   - Project Settings → Cloud Messaging
   - Copy Server Key

3. **Install Dependencies**
   ```bash
   pip install firebase-admin
   ```

4. **Update Service**
   ```python
   import firebase_admin
   from firebase_admin import credentials, messaging
   
   # Initialize
   cred = credentials.Certificate("path/to/serviceAccountKey.json")
   firebase_admin.initialize_app(cred)
   
   # Send notification
   message = messaging.Message(
       notification=messaging.Notification(
           title=title,
           body=body,
       ),
       data=data,
       token=user_token,
   )
   messaging.send(message)
   ```

### Apple Push Notification Service (APNs)

1. **Create APNs Key**
   - Apple Developer Portal
   - Create APNs Auth Key
   - Download .p8 file

2. **Install Dependencies**
   ```bash
   pip install PyAPNs2
   ```

3. **Update Service**
   ```python
   from apns2.client import APNsClient
   from apns2.payload import Payload
   
   client = APNsClient('path/to/key.p8', use_sandbox=False)
   payload = Payload(alert=body, badge=1, sound="default")
   client.send_notification(token, payload, topic="com.talkam.liberia")
   ```

## Next Steps

1. **Integrate FCM/APNs** - Replace stub with real push notification service
2. **Store Device Tokens** - Add user device token management
3. **Notification Preferences** - Allow users to configure notification types
4. **Analytics Dashboard UI** - Build admin dashboard with new analytics
5. **Search UI** - Add advanced search filters to mobile/web apps

---

**Status**: ✅ Analytics and search enhancements complete!
