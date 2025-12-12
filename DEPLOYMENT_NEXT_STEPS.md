# 🚀 Deployment Next Steps - Error Fixes

## ✅ Code Changes Pushed

All error fixes have been committed and pushed to GitHub:
- ✅ Media upload error handling improved
- ✅ Reports search error handling improved
- ✅ Better S3 error messages
- ✅ Graceful degradation for database errors

---

## 📋 Step 1: Verify Koyeb Auto-Deployment

Koyeb should automatically deploy from GitHub when changes are pushed.

### Check Deployment Status:

1. **Go to Koyeb Dashboard:**
   - Visit: https://app.koyeb.com
   - Navigate to your service: `little-amity-talkam`

2. **Check Recent Deployments:**
   - Look for a new deployment triggered by the latest commit
   - Status should show "Building" or "Running"

3. **If Auto-Deploy Didn't Trigger:**
   - Click "Redeploy" button in Koyeb dashboard
   - Or trigger manually via: Settings → Redeploy

---

## 🔍 Step 2: Verify Environment Variables

Ensure these environment variables are set in Koyeb:

### Required Variables:
```bash
DATABASE_URL=postgres://...          # ✅ Should be auto-set by Koyeb
SECRET_KEY=your-secret-key           # ✅ Required
JWT_SECRET=your-jwt-secret          # ✅ Required
REDIS_URL=redis://...               # ✅ Required
CORS_ORIGINS=*                       # ✅ Required
ENVIRONMENT=production               # ✅ Required
```

### Optional (for Media Upload):
```bash
S3_ENDPOINT=https://...              # ⚠️ Optional - for media uploads
S3_ACCESS_KEY=...                     # ⚠️ Optional - for media uploads
S3_SECRET_KEY=...                     # ⚠️ Optional - for media uploads
BUCKET_REPORTS=talkam-media          # ⚠️ Optional - defaults to "talkam-media"
```

### To Check/Update in Koyeb:
1. Go to your service → Settings → Environment Variables
2. Verify all required variables are set
3. Add missing optional variables if you want media uploads to work

---

## 🧪 Step 3: Test the Fixes

### Test 1: Health Check
```bash
curl https://little-amity-talkam-c84a1504.koyeb.app/health
```

**Expected:** `{"status":"healthy"}`

### Test 2: API Health
```bash
curl https://little-amity-talkam-c84a1504.koyeb.app/v1/health
```

**Expected:** `{"status":"healthy"}`

### Test 3: Reports Search (Map Endpoint)
```bash
curl -X GET "https://little-amity-talkam-c84a1504.koyeb.app/v1/reports/search" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** 
- ✅ Returns 200 with results (or empty array if no reports)
- ❌ Should NOT return 500 error

### Test 4: Media Upload Endpoint
```bash
curl -X POST "https://little-amity-talkam-c84a1504.koyeb.app/v1/media/upload" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type": "photo"}'
```

**Expected:**
- ✅ If S3 configured: Returns presigned URL
- ✅ If S3 NOT configured: Returns 503 with clear message
- ❌ Should NOT return 500 error

---

## 📱 Step 4: Test Mobile App

### Rebuild APK with Fixes:
```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### Install on Device:
```bash
flutter install
# OR
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Test in App:
1. **Test Map View:**
   - Navigate to Map tab
   - Should load without 500 error
   - Should show map (even if empty)

2. **Test Media Upload:**
   - Go to "Report an issue"
   - Try to upload a photo
   - Should either:
     - ✅ Upload successfully (if S3 configured)
     - ✅ Show clear error message (if S3 not configured)
     - ❌ Should NOT show generic 500 error

---

## 🔧 Step 5: Check Koyeb Logs

If errors persist, check logs:

1. **In Koyeb Dashboard:**
   - Go to your service → Logs
   - Look for recent error messages
   - Check for S3 connection errors
   - Check for database errors

2. **Common Issues:**

   **S3 Errors:**
   - "Bucket not found" → Check `BUCKET_REPORTS` variable
   - "Access denied" → Check `S3_ACCESS_KEY` and `S3_SECRET_KEY`
   - "Connection refused" → Check `S3_ENDPOINT`

   **Database Errors:**
   - "Connection refused" → Check `DATABASE_URL`
   - "Authentication failed" → Check database credentials

---

## ✅ Verification Checklist

- [ ] Code pushed to GitHub
- [ ] Koyeb deployment triggered/complete
- [ ] Health endpoint returns 200
- [ ] API health endpoint returns 200
- [ ] Reports search returns 200 (not 500)
- [ ] Media upload returns appropriate status (503 or 200, not 500)
- [ ] Mobile app rebuilt with latest code
- [ ] Map view loads without errors
- [ ] Media upload shows proper error messages

---

## 🎯 Expected Behavior After Fixes

### Before Fixes:
- ❌ Media upload: Generic 500 error
- ❌ Map view: Generic 500 error
- ❌ No helpful error messages

### After Fixes:
- ✅ Media upload: Clear error if S3 not configured (503)
- ✅ Map view: Returns empty results gracefully (200)
- ✅ Helpful error messages for all failures
- ✅ Better logging for debugging

---

## 📞 If Issues Persist

1. **Check Koyeb Logs:**
   - Service → Logs tab
   - Look for stack traces
   - Share error details

2. **Verify Environment Variables:**
   - All required vars are set
   - Values are correct (no typos)

3. **Test Endpoints Manually:**
   - Use curl or Postman
   - Check response codes
   - Check response bodies

4. **Database Migration:**
   - Ensure migrations are up to date
   - Check database connection

---

## 🚀 Quick Deploy Commands

### Manual Redeploy (if needed):
```bash
# Trigger via Koyeb dashboard or CLI
koyeb service redeploy little-amity-talkam
```

### Check Deployment Status:
```bash
curl -I https://little-amity-talkam-c84a1504.koyeb.app/health
```

---

**All fixes are in place! Follow these steps to verify deployment.** 🎉
