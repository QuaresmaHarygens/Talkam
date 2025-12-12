# 🚀 Community Challenge Module - Deployment Guide

## ✅ Module Implementation Complete!

The Community Challenge & Social Work Hub module has been fully implemented and pushed to GitHub.

---

## 📦 What Was Created

### Backend (46 files changed, 8430+ lines added)

#### Database Models
- `backend/app/models/challenges.py` - 4 models:
  - `CommunityChallenge` - Main challenge entity
  - `ChallengeParticipation` - User participation
  - `ChallengeProgress` - Progress updates
  - `StakeholderSupport` - NGO/government support

#### API Endpoints
- `backend/app/api/challenges.py` - 8 endpoints:
  - `POST /v1/challenges/create` - Create challenge
  - `GET /v1/challenges/list` - List with geo-filtering
  - `GET /v1/challenges/{id}` - Get details
  - `POST /v1/challenges/{id}/join` - Join challenge
  - `POST /v1/challenges/{id}/progress` - Add progress
  - `POST /v1/challenges/{id}/support` - Stakeholder support
  - `GET /v1/challenges/{id}/progress` - Get progress updates
  - `GET /v1/challenges/{id}/participants` - Get participants

#### Services
- `backend/app/services/geo_clustering.py` - Geo-location clustering (2-5km radius)
- `backend/app/services/challenge_notifications.py` - Notification system

#### Schemas
- `backend/app/schemas/challenge.py` - Pydantic models

#### Migration
- `backend/alembic/versions/001_add_community_challenges.py` - Database migration

---

### Mobile App

#### Models
- `mobile/lib/models/challenge.dart` - Challenge data models

#### API Client
- `mobile/lib/api/client.dart` - 8 new methods for challenge operations

#### UI Screens
- `mobile/lib/screens/community/community_hub_screen.dart` - Main hub
- `mobile/lib/screens/community/create_challenge_screen.dart` - Create challenge
- `mobile/lib/screens/community/challenge_detail_screen.dart` - Challenge details
- `mobile/lib/screens/community/challenge_progress_screen.dart` - Progress timeline

#### Navigation
- Updated `mobile/lib/screens/home_screen.dart` - Added Community tab

---

## 🗄️ Database Migration

### Step 1: Apply Migration

**On Koyeb (or locally):**

The migration file is at: `backend/alembic/versions/001_add_community_challenges.py`

**To apply:**
```bash
cd backend
alembic upgrade head
```

**Or if using Koyeb:**
- The migration will run automatically if you have a release command configured
- Or run manually via Koyeb console/SSH

**Tables created:**
- `community_challenges`
- `challenge_participations`
- `challenge_progress`
- `stakeholder_supports`

**Schema updates:**
- `notifications` table: Added `challenge_id` (nullable)
- `notifications` table: Made `report_id` nullable

---

## 🚀 Deployment Steps

### 1. Backend Deployment

**Code is already pushed to GitHub ✅**

**In Koyeb:**
1. Go to your service dashboard
2. Click "Redeploy" button
3. Wait 5-10 minutes for deployment
4. Migration should run automatically (if release command is configured)

**Or manually run migration:**
```bash
# Via Koyeb console or SSH
cd backend
alembic upgrade head
```

---

### 2. Mobile App Rebuild

**Rebuild the APK with new Community module:**

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

**Or install directly on connected device:**
```bash
flutter install
```

---

## 🧪 Testing

### Backend API Testing

**1. Create Challenge:**
```bash
curl -X POST https://little-amity-talkam-c84a1504.koyeb.app/v1/challenges/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Community Clean-up Drive",
    "description": "Let's clean up our neighborhood and make it beautiful",
    "category": "environmental",
    "latitude": 6.4281,
    "longitude": -10.7619,
    "urgency_level": "medium",
    "duration_days": 30
  }'
```

**2. List Challenges:**
```bash
curl "https://little-amity-talkam-c84a1504.koyeb.app/v1/challenges/list?latitude=6.4281&longitude=-10.7619&radius_km=5.0" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**3. Join Challenge:**
```bash
curl -X POST https://little-amity-talkam-c84a1504.koyeb.app/v1/challenges/CHALLENGE_ID/join \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "volunteer"}'
```

---

### Mobile App Testing

1. **Open app** → Navigate to "Community" tab
2. **Create Challenge:**
   - Tap "+" button
   - Fill in details
   - Select category
   - Get location
   - Submit
3. **Join Challenge:**
   - Tap on a challenge
   - Tap "Join" or "Volunteer"
4. **Add Progress:**
   - In challenge details
   - Add progress update
   - Upload photos/videos
5. **View Progress:**
   - See timeline of updates
   - View media gallery

---

## 📋 Feature Checklist

### ✅ Implemented Features

- [x] Create challenges with categories
- [x] Join challenges (participant, volunteer, donor)
- [x] Track progress with percentage
- [x] Upload media (photos, videos)
- [x] Geo-location clustering (2-5km radius)
- [x] Real-time notifications
- [x] Stakeholder support (NGOs, government)
- [x] Progress timeline
- [x] Participant management
- [x] Category filtering
- [x] Urgency levels
- [x] Resource tracking
- [x] Status management
- [x] Auto-complete at 100%

---

## 🎯 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/challenges/create` | Create new challenge |
| GET | `/v1/challenges/list` | List challenges (geo-filtered) |
| GET | `/v1/challenges/{id}` | Get challenge details |
| POST | `/v1/challenges/{id}/join` | Join challenge |
| POST | `/v1/challenges/{id}/progress` | Add progress update |
| POST | `/v1/challenges/{id}/support` | Stakeholder support |
| GET | `/v1/challenges/{id}/progress` | Get progress updates |
| GET | `/v1/challenges/{id}/participants` | Get participants |

---

## 📱 Mobile App Navigation

**Bottom Navigation:**
1. **Home** - Reports feed
2. **Community** - Challenge hub (NEW) ⭐
3. **Map** - Map view
4. **Notifications** - Notifications
5. **Settings** - Settings

---

## 🔔 Notification Types

The module creates notifications for:
- `challenge_created` - New challenge in your area
- `challenge_progress` - Progress update on joined challenge
- `volunteer_request` - Volunteers needed
- `stakeholder_support` - NGO/government support received

---

## 📝 Important Notes

1. **Database Migration Required:**
   - Must run `alembic upgrade head` before using the module
   - Migration creates 4 new tables
   - Updates `notifications` table schema

2. **Location Permissions:**
   - Already added to AndroidManifest.xml
   - App will request permission on first use

3. **Geo-Clustering:**
   - Default radius: 5km
   - Configurable via API parameter
   - Uses Haversine formula for distance calculation

4. **Notifications:**
   - Currently notifies all verified users
   - Can be optimized with user location tracking (future enhancement)

5. **Media Upload:**
   - Requires S3 configuration
   - Will show clear error if S3 not configured

---

## 🎉 Ready to Deploy!

**All code is pushed to GitHub and ready for deployment.**

**Next steps:**
1. ✅ Code pushed to GitHub
2. ⏳ Run database migration
3. ⏳ Redeploy backend to Koyeb
4. ⏳ Rebuild mobile app APK
5. ⏳ Test the module!

---

**The Community Challenge module is complete and ready to use!** 🚀

