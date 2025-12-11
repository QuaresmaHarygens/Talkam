# 🔐 Login Credentials - Test Accounts

## 📱 Mobile App & Admin Dashboard Login

### Admin User (Full Access)
- **Phone**: `231770000001`
- **Password**: `AdminPass123!`
- **Role**: Administrator
- **Access**: Full system access, can manage all reports, users, and settings

### Regular User
- **Phone**: `231770000003`
- **Password**: `UserPass123!`
- **Role**: Regular User
- **Access**: Can create reports, view reports, attest to reports

### NGO User
- **Phone**: `231770000002`
- **Password**: `NGOPass123!`
- **Role**: NGO/Verifier
- **Access**: Can verify reports, view analytics

## 🚀 Quick Login Steps

### On Mobile App (Android APK)
1. Open the app
2. Tap "Log in" tab
3. Enter phone number: `231770000003`
4. Enter password: `UserPass123!`
5. Tap "Log in" button

### On Admin Dashboard (Web)
1. Open: http://localhost:3000 (or your admin dashboard URL)
2. Enter phone: `231770000001`
3. Enter password: `AdminPass123!`
4. Click "Login"

## 🔄 Alternative: Anonymous Mode

**No login required!**
- Tap "Start Anonymous" button
- App works in anonymous mode
- Can create reports without account
- Limited functionality

## 📝 Create New Account

### On Mobile App
1. Open app
2. Tap "Sign up" tab
3. Enter:
   - Full Name
   - Phone Number (e.g., `231770000999`)
   - Password (min 8 characters)
   - Email (optional)
4. Tap "Sign up"

### Via API
```bash
curl -X POST http://127.0.0.1:8000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Your Name",
    "phone": "231770000999",
    "password": "YourPass123!",
    "email": "your@email.com"
  }'
```

## ⚠️ Important Notes

1. **Backend Must Be Running**
   - These credentials only work if backend is running
   - Backend URL: http://127.0.0.1:8000
   - For Android emulator: http://10.0.2.2:8000

2. **Database Must Be Seeded**
   - If users don't exist, run seed script:
   ```bash
   cd backend
   source .venv/bin/activate
   python scripts/seed_data.py
   ```

3. **Password Requirements**
   - Minimum 8 characters
   - Recommended: Mix of letters, numbers, and special characters

## 🧪 Testing Different Roles

### Test Admin Features
- Login as: `231770000001` / `AdminPass123!`
- Can access admin dashboard
- Can manage all reports
- Can view analytics

### Test Regular User
- Login as: `231770000003` / `UserPass123!`
- Can create reports
- Can view reports feed
- Can attest to reports

### Test NGO/Verifier
- Login as: `231770000002` / `NGOPass123!`
- Can verify reports
- Can view verification dashboard

## 🔍 Verify Backend is Running

```bash
# Check health
curl http://127.0.0.1:8000/health

# Should return: {"status":"healthy","service":"talkam-api"}
```

## 🐛 Troubleshooting

### "Login failed" or "Invalid credentials"
1. **Check backend is running**
   ```bash
   curl http://127.0.0.1:8000/health
   ```

2. **Verify users exist in database**
   ```bash
   cd backend
   source .venv/bin/activate
   python scripts/seed_data.py
   ```

3. **Check API endpoint**
   - Mobile app: Should use `http://10.0.2.2:8000/v1` (Android emulator)
   - Admin dashboard: Should use `http://127.0.0.1:8000/v1`

### "Connection refused"
- Backend not running
- Start backend: `cd backend && uvicorn app.main:app --reload`

## 📋 Summary

| User Type | Phone | Password | Use Case |
|-----------|-------|----------|----------|
| **Admin** | `231770000001` | `AdminPass123!` | Full access, management |
| **NGO** | `231770000002` | `NGOPass123!` | Report verification |
| **User** | `231770000003` | `UserPass123!` | Regular reporting |

---

**Quick Login:**
- **Phone**: `231770000003`
- **Password**: `UserPass123!`

**Or use Anonymous Mode** - No login required! 🎉

