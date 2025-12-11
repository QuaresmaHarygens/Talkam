# Mobile App Attestation Integration

## ✅ Completed Integration

### 1. API Client Updates
- Added `getNotifications()` - Fetch user notifications
- Added `markNotificationRead()` - Mark notification as read
- Added `getUnreadCount()` - Get count of unread notifications
- Added `attestToReport()` - Submit attestation to a report

### 2. Notifications Screen
- **Full Implementation**: Displays all notifications with:
  - Unread badge count in app bar
  - Visual indicators (read/unread, action taken)
  - Tap to view report details
  - Auto-mark as read when opened
  - Pull-to-refresh

### 3. Report Detail Screen
- **Attestation Button**: Shows notification badge if user has attestation request
- **Attestation Dialog**: Full UI for attesting with:
  - Action selection (Confirm/Deny/Needs Info)
  - Confidence level (High/Medium/Low) for confirmations
  - Optional comment field
  - Location inclusion option (calculates distance)
  - Success feedback

### 4. Home Screen
- **Unread Badge**: Shows unread notification count on notifications tab
- **Auto-refresh**: Loads unread count on screen load

## User Flow

### Receiving Attestation Request

1. **User A creates a report** in Montserrado County
2. **User B (in same county) receives notification**:
   - Badge appears on notifications tab
   - Notification shows in notifications list
   - Unread indicator (blue background)

### Attesting to Report

1. **User B opens notification**:
   - Taps notification → Opens report detail
   - Notification automatically marked as read
   
2. **User B attests**:
   - Taps notification badge or "Attest" button
   - Selects action (Confirm/Deny/Needs Info)
   - Optionally adds confidence level and comment
   - Can include location for distance calculation
   - Submits attestation

3. **System updates**:
   - Attestation recorded
   - Report witness count increases (if confirmed)
   - Success message shown
   - Notification marked as action taken

## UI Features

### Notifications Screen
- **Color coding**:
  - Blue background = Unread
  - Green checkmark = Action taken
  - Grey = Read
  
- **Information displayed**:
  - Report title and message
  - Category and severity
  - Timestamp
  - Action status

### Attestation Dialog
- **Action buttons**: Segmented control for easy selection
- **Confidence levels**: Only shown for "Confirm" action
- **Location option**: Checkbox to include GPS coordinates
- **Comment field**: Optional text input for additional info

## Testing

### Test Notification Flow

1. **Create test users** (if not already seeded):
   ```bash
   # Use seed script or create via API
   ```

2. **Create report as User A**:
   - Use mobile app or API
   - Set location in a county with other users

3. **Check notifications as User B**:
   - Open mobile app
   - Navigate to Notifications tab
   - Should see new notification

4. **Attest to report**:
   - Tap notification
   - Tap attestation button
   - Select "Confirm" with "High" confidence
   - Add comment
   - Submit

5. **Verify**:
   - Notification should show green checkmark
   - Report witness count should increase
   - Attestation should appear in backend

### API Testing

```bash
# Get notifications
curl -X GET http://127.0.0.1:8000/v1/notifications \
  -H "Authorization: Bearer <token>"

# Attest to report
curl -X POST http://127.0.0.1:8000/v1/attestations/reports/<report_id>/attest \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "confirm",
    "confidence": "high",
    "comment": "I saw this too"
  }'
```

## Future Enhancements

1. **Push Notifications**: Real-time alerts when new attestation requests arrive
2. **In-app Badge**: Persistent badge on home screen icon
3. **Attestation History**: View all attestations user has made
4. **Quick Actions**: Swipe actions on notifications (confirm/deny)
5. **Location Auto-detect**: Automatically include location if permission granted
6. **Attestation Stats**: Show how many people have attested to a report

## Known Limitations

1. **Notification Polling**: Currently requires manual refresh or screen load
   - Future: Implement WebSocket or push notifications for real-time updates

2. **Location Permission**: User must grant location permission for distance calculation
   - Future: Better permission handling and explanation

3. **Notification Filtering**: No filtering by type or date yet
   - Future: Add filters (attestation requests, status updates, etc.)

---

**Status**: ✅ Fully integrated and ready for testing!
