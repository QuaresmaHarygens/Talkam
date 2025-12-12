# 🌐 Web Frontend API Integration

## ✅ Completed Integration

### 1. Real API Client Created
- ✅ Created `/web-app/lib/api/client.ts` with full API client
- ✅ Supports authentication (login, register, anonymous)
- ✅ Supports all endpoints (reports, challenges, notifications, verify, media)
- ✅ Automatic token management (localStorage)
- ✅ Error handling and network error detection

### 2. Dashboard Integration
- ✅ Replaced mock API with real API calls
- ✅ Added loading states
- ✅ Added error handling with retry
- ✅ Data transformation from API format to UI format

### 3. Login Integration
- ✅ Real authentication with backend
- ✅ Support for phone/email login
- ✅ Registration flow
- ✅ Guest mode with anonymous token
- ✅ Error messages for failed auth

---

## 📋 Integration Status

| Page | Status | Notes |
|------|--------|-------|
| Dashboard | ✅ Integrated | Using real API |
| Login | ✅ Integrated | Real auth |
| Report | ⏳ Pending | Still using mock |
| Verify | ⏳ Pending | Still using mock |
| Challenges | ⏳ Pending | Still using mock |
| Map | ⏳ Pending | Still using mock |
| Notifications | ⏳ Pending | Still using mock |
| Profile | ⏳ Pending | Still using mock |

---

## 🔧 API Client Usage

### Basic Usage

```typescript
import { apiClient } from "@/lib/api/client"

// Set token (automatically done on login)
apiClient.setToken(token)

// Search reports
const reports = await apiClient.searchReports({
  page: 1,
  page_size: 10,
  category: "infrastructure"
})

// Create report
const newReport = await apiClient.createReport({
  summary: "Pothole on Main Street",
  details: "Large pothole causing traffic issues",
  category: "infrastructure",
  severity: "medium",
  latitude: 6.4281,
  longitude: -10.7619,
  county: "Montserrado"
})

// List challenges
const challenges = await apiClient.listChallenges({
  lat: 6.4281,
  lng: -10.7619,
  radius_km: 5
})
```

### Error Handling

```typescript
try {
  const data = await apiClient.searchReports()
} catch (error) {
  if (error instanceof Error) {
    console.error(error.message)
    // Handle specific error types
    if (error.message.includes('401')) {
      // Redirect to login
    }
  }
}
```

---

## 🔄 Data Transformation

The API client transforms backend data to match the frontend's expected format:

### Reports
```typescript
// Backend format
{
  id: "uuid",
  summary: "Report summary",
  category: "infrastructure",
  severity: "medium",
  status: "submitted",
  location: { latitude: 6.4281, longitude: -10.7619 },
  county: "Montserrado",
  created_at: "2025-12-08T10:00:00Z"
}

// Frontend format
{
  id: "uuid",
  summary: "Report summary",
  category: "infrastructure",
  severity: "medium",
  status: "submitted",
  location: {
    latitude: 6.4281,
    longitude: -10.7619,
    county: "Montserrado"
  },
  createdAt: "2025-12-08T10:00:00Z"
}
```

---

## 🚀 Next Steps

### High Priority
1. **Update Report Page** (`/app/report/page.tsx`)
   - Replace mock API with `apiClient.createReport()`
   - Add media upload using `apiClient.requestUploadUrl()`
   - Add location picker integration

2. **Update Verify Page** (`/app/verify/page.tsx`)
   - Replace mock API with `apiClient.searchReports()`
   - Add verification using `apiClient.verifyReport()`

3. **Update Challenges Pages**
   - `/app/challenges/page.tsx` - Use `apiClient.listChallenges()`
   - `/app/challenges/new/page.tsx` - Use `apiClient.createChallenge()`
   - `/app/challenges/[id]/page.tsx` - Use `apiClient.getChallenge()`

### Medium Priority
4. **Update Notifications Page**
   - Use `apiClient.getNotifications()`
   - Add mark as read functionality

5. **Update Profile Page**
   - Add user stats from API
   - Add user's reports/challenges

6. **Add Environment Variables**
   - Create `.env.local` for API URL
   - Support different environments (dev, staging, prod)

---

## 🔐 Authentication Flow

### Login Flow
1. User enters phone/email and password
2. `apiClient.login()` called
3. Token stored in localStorage
4. User data stored in Zustand store
5. Redirect to dashboard

### Guest Flow
1. User clicks "Continue as Guest"
2. `apiClient.anonymousStart()` called with device hash
3. Anonymous token stored
4. User marked as guest in store
5. Redirect to dashboard

### Token Management
- Token automatically included in all requests
- Token stored in localStorage
- Token cleared on logout
- Automatic redirect to login on 401 errors (to be implemented)

---

## 🐛 Known Issues

1. **Phone vs Email Login**
   - Backend expects phone for login
   - Frontend allows email as fallback
   - May need backend update or frontend validation

2. **Data Format Mismatches**
   - Some field names differ between backend and frontend
   - Transformation layer handles this
   - May need adjustments as backend evolves

3. **Error Handling**
   - Generic error messages
   - Could be more specific per error type
   - Network errors vs API errors

---

## 📝 Environment Variables

Create `.env.local` in `web-app/`:

```env
NEXT_PUBLIC_API_URL=https://little-amity-talkam-c84a1504.koyeb.app/v1
```

Or use default (already configured in client.ts)

---

## ✅ Testing Checklist

- [ ] Login with phone
- [ ] Login with email (if supported)
- [ ] Registration flow
- [ ] Guest mode
- [ ] Dashboard loads reports
- [ ] Dashboard loads notifications
- [ ] Error handling on network failure
- [ ] Error handling on auth failure
- [ ] Token persistence across page reloads
- [ ] Logout clears token

---

**Last Updated**: December 8, 2025  
**Status**: Dashboard & Login Integrated ✅
