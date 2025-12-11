# Quick Fix: Running Mobile App

## ❌ Wrong Way (from backend directory):
```bash
cd backend
cd mobile  # ❌ This fails - mobile is not inside backend
flutter run
```

## ✅ Correct Way:

### Option 1: From Project Root
```bash
cd /Users/visionalventure/Watch\ Liberia
cd mobile
flutter run
```

### Option 2: Direct Path
```bash
cd /Users/visionalventure/Watch\ Liberia/mobile
flutter run
```

### Option 3: One-liner from Anywhere
```bash
cd /Users/visionalventure/Watch\ Liberia/mobile && flutter run
```

## 📁 Directory Structure:
```
Watch Liberia/          ← Project root
├── backend/           ← Backend API
├── mobile/            ← Flutter app (sibling of backend)
└── admin-web/         ← React dashboard
```

**Key Point:** `mobile/` is a **sibling** of `backend/`, not inside it!
