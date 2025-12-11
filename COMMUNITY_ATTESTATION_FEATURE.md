# Community Attestation Feature

## Overview

When a report is created, community members within the same area (county) automatically receive notifications asking them to attest to the report. This enables crowd-sourced verification and helps build trust in the reporting system.

## How It Works

### 1. Report Creation Triggers Notifications

When a user creates a report:
- The system identifies users in the same county (or within a radius)
- Notifications are sent to those users in the background
- The report creation response is not blocked by notification sending

### 2. Notification System

**Database Tables:**
- `notifications` - Stores notifications sent to users
- `attestations` - Stores community member attestations

**Notification Fields:**
- `user_id` - User who receives the notification
- `report_id` - Report being attested to
- `title` - "New Report in [County]"
- `message` - Description asking for attestation
- `read` - Whether user has seen the notification
- `action_taken` - Whether user has attested

### 3. Attestation Process

Community members can attest to reports in three ways:

1. **Confirm** - User confirms the report is accurate
   - Increases report's `witness_count`
   - Adds confidence to the report

2. **Deny** - User disputes the report
   - Flags potential issues
   - May trigger review

3. **Needs Info** - User needs more information
   - Can request additional details
   - Helps improve report quality

### 4. Distance Tracking

If users provide their location when attesting:
- System calculates distance from report location
- Stored in `distance_km` field
- Helps verify proximity and credibility

## API Endpoints

### Get Notifications
```
GET /v1/notifications
```
Returns all notifications for the authenticated user.

**Query Parameters:**
- `unread_only` (bool) - Only return unread notifications
- `limit` (int) - Maximum number to return (default: 50, max: 100)

**Response:**
```json
[
  {
    "id": "uuid",
    "report_id": "uuid",
    "title": "New Report in Montserrado",
    "message": "A high infrastructure issue was reported near you...",
    "read": false,
    "action_taken": false,
    "created_at": "2025-12-09T00:00:00Z",
    "report_summary": "Road blocked by fallen tree",
    "report_category": "infrastructure",
    "report_severity": "high"
  }
]
```

### Mark Notification as Read
```
POST /v1/notifications/{notification_id}/read
```
Marks a notification as read.

### Get Unread Count
```
GET /v1/notifications/unread/count
```
Returns count of unread notifications.

**Response:**
```json
{
  "unread_count": 5
}
```

### Attest to Report
```
POST /v1/attestations/reports/{report_id}/attest
```

**Request Body:**
```json
{
  "action": "confirm",  // "confirm", "deny", or "needs_info"
  "confidence": "high",  // "high", "medium", or "low" (optional)
  "comment": "I saw this too, it's accurate",  // Optional
  "latitude": 6.4281,  // Optional - for distance calculation
  "longitude": -10.7619  // Optional - for distance calculation
}
```

**Response:**
```json
{
  "id": "uuid",
  "report_id": "uuid",
  "action": "confirm",
  "distance_km": 2.5,
  "message": "Thank you for your attestation. Your confirm has been recorded."
}
```

## Implementation Details

### Location Matching

Currently, the system matches users by:
- **County** - Users in the same county as the report
- Future: Can be enhanced with:
  - User's last known location
  - Geospatial queries (PostGIS)
  - Distance-based radius matching

### Background Processing

Notifications are sent asynchronously:
- Report creation is not blocked
- Uses asyncio background tasks
- In production, use a proper task queue (Celery, RQ, etc.)

### Privacy Considerations

- Users can attest anonymously (if using anonymous tokens)
- Distance is calculated but not exposed to other users
- Reporter's identity is protected if report is anonymous

## Mobile App Integration

The mobile app should:

1. **Display Notifications**
   - Show notification badge on home screen
   - List notifications in notifications tab
   - Allow tapping to view report details

2. **Attestation UI**
   - Show "Attest" button on report detail screen
   - Allow selecting action (confirm/deny/needs_info)
   - Optional: Request location for distance calculation
   - Show thank you message after attestation

3. **Real-time Updates**
   - Poll for new notifications periodically
   - Update unread count badge
   - Show notification when new attestation request arrives

## Example Flow

1. **User A creates a report** about a pothole in Montserrado County
2. **System finds users** in Montserrado County (User B, C, D)
3. **Notifications sent** to User B, C, D
4. **User B opens app** and sees notification
5. **User B views report** and taps "Attest"
6. **User B confirms** the report with high confidence
7. **System updates**:
   - Report's `witness_count` increases
   - Attestation is recorded
   - Notification marked as `action_taken = true`

## Future Enhancements

1. **Push Notifications** - Real-time alerts via FCM/APNs
2. **SMS Fallback** - For users without app
3. **Geospatial Matching** - More precise location-based matching
4. **Attestation Scoring** - Weight attestations by user reputation
5. **Threshold-based Auto-Verification** - Auto-verify reports with enough confirmations
6. **Community Leaderboards** - Recognize active community members

## Testing

To test the feature:

1. **Create a report:**
   ```bash
   curl -X POST http://127.0.0.1:8000/v1/reports/create \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{
       "category": "infrastructure",
       "severity": "high",
       "summary": "Test report",
       "location": {"latitude": 6.4281, "longitude": -10.7619, "county": "Montserrado"}
     }'
   ```

2. **Check notifications** (as another user):
   ```bash
   curl http://127.0.0.1:8000/v1/notifications \
     -H "Authorization: Bearer <other_user_token>"
   ```

3. **Attest to report:**
   ```bash
   curl -X POST http://127.0.0.1:8000/v1/attestations/reports/<report_id>/attest \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{
       "action": "confirm",
       "confidence": "high",
       "comment": "I saw this too"
     }'
   ```

---

**Status**: ✅ Implemented and ready for testing!
