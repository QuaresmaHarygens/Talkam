# Quick Start Commands

## 🚀 Starting Services

### From Project Root:

**Terminal 1: Backend API**
```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload
```

**Terminal 2: Admin Dashboard**
```bash
cd admin-web
npm run dev
```

**Terminal 3: Mobile App**
```bash
cd mobile
flutter run
```

## 📍 Current Directory Matters!

If you're in `mobile/` directory:
- ❌ `cd backend` won't work
- ✅ `cd ../backend` will work
- ✅ Or go to root first: `cd /Users/visionalventure/Watch\ Liberia/backend`

## 🎯 Correct Commands from Anywhere:

**From mobile directory:**
```bash
cd ../backend && source .venv/bin/activate && uvicorn app.main:app --reload
```

**From project root:**
```bash
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload
```

## 💡 Helper Scripts:

```bash
# From project root
./scripts/start_all.sh  # Starts backend + admin

# Or individually
./scripts/start_backend.sh
```

## 📋 Directory Structure:

```
Watch Liberia/
├── backend/          # Python FastAPI
├── mobile/           # Flutter app
├── admin-web/        # React dashboard
└── scripts/          # Helper scripts
```

Always run commands from the correct directory! 🎯
