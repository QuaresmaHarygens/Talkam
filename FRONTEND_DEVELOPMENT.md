# Frontend Development Guide

Complete guide for developing the Talkam Liberia frontend applications.

## 🎯 Frontend Applications

1. **Mobile App (Flutter)** - iOS and Android
2. **Admin Dashboard (React)** - Web dashboard

## 📱 Mobile App (Flutter)

### Prerequisites

1. **Install Flutter SDK**
   ```bash
   # macOS
   brew install --cask flutter
   
   # Or download from: https://flutter.dev/docs/get-started/install
   ```

2. **Verify Installation**
   ```bash
   flutter doctor
   ```

3. **Install Dependencies**
   ```bash
   cd mobile
   flutter pub get
   ```

### Configuration

Update API endpoint in `mobile/lib/providers.dart` or `mobile/lib/api/client.dart`:

```dart
final apiBaseUrl = 'http://127.0.0.1:8000/v1';  // Local development
// final apiBaseUrl = 'https://api.talkam.liberia.com/v1';  // Production
```

**For Android Emulator:** Use `10.0.2.2` instead of `127.0.0.1`

### Running the Mobile App

```bash
cd mobile

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run on iOS Simulator (macOS only)
open -a Simulator
flutter run

# Run on Android Emulator
flutter emulators --launch <emulator-id>
flutter run
```

### Development Workflow

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` in terminal
3. **Stop**: Press `q` in terminal

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release

# App Bundle for Play Store
flutter build appbundle
```

## 🌐 Admin Dashboard (React)

### Prerequisites

1. **Install Node.js 18+**
   ```bash
   # macOS
   brew install node
   
   # Or download from: https://nodejs.org/
   ```

2. **Install Dependencies**
   ```bash
   cd admin-web
   npm install
   ```

### Configuration

Create `.env` file in `admin-web/`:

```bash
VITE_API_URL=http://127.0.0.1:8000/v1
```

### Running the Admin Dashboard

```bash
cd admin-web

# Install dependencies (first time only)
npm install

# Start development server
npm run dev
```

Dashboard will be available at: **http://localhost:3000**

### Development Features

- Hot module replacement (HMR)
- TypeScript support
- React Query for data fetching
- Responsive design

### Building for Production

```bash
cd admin-web
npm run build

# Output will be in dist/ directory
# Deploy to Vercel, Netlify, or any static host
```

## 🔗 API Integration

### Backend API

Ensure backend is running:
```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload
```

API will be at: **http://127.0.0.1:8000**

### API Documentation

- **Swagger UI**: http://127.0.0.1:8000/docs
- **ReDoc**: http://127.0.0.1:8000/redoc

### Test Credentials

For testing frontend apps:

**Admin User:**
- Phone: `231770000001`
- Password: `AdminPass123!`

**Regular User:**
- Phone: `231770000003`
- Password: `UserPass123!`

## 🛠️ Development Setup

### Quick Start (All Frontends)

```bash
# Terminal 1: Backend API
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload

# Terminal 2: Admin Dashboard
cd admin-web
npm run dev

# Terminal 3: Mobile App
cd mobile
flutter run
```

### Recommended Development Tools

**For Mobile (Flutter):**
- Android Studio (Android development)
- Xcode (iOS development, macOS only)
- VS Code with Flutter extension

**For Admin Dashboard:**
- VS Code with React extensions
- Chrome DevTools
- React Developer Tools extension

## 📁 Frontend Project Structure

### Mobile App (`mobile/`)

```
mobile/
├── lib/
│   ├── api/              # API client
│   ├── models/           # Data models
│   ├── screens/          # UI screens
│   ├── services/         # Business logic
│   ├── widgets/          # Reusable widgets
│   └── providers.dart    # State management
├── assets/               # Images, fonts
└── pubspec.yaml          # Dependencies
```

### Admin Dashboard (`admin-web/`)

```
admin-web/
├── src/
│   ├── components/       # React components
│   ├── pages/            # Page components
│   ├── services/         # API services
│   ├── utils/            # Utilities
│   └── App.tsx           # Main app
├── public/               # Static assets
└── package.json          # Dependencies
```

## 🧪 Testing

### Mobile App Testing

```bash
cd mobile
flutter test
```

### Admin Dashboard Testing

```bash
cd admin-web
npm test  # If tests are set up
```

## 🐛 Troubleshooting

### Mobile App Issues

**"No devices found"**
```bash
flutter devices
flutter emulators --launch <emulator-name>
```

**API Connection Issues**
- For Android emulator: Use `10.0.2.2` instead of `127.0.0.1`
- For iOS simulator: Use `localhost` or `127.0.0.1`
- Check backend is running on port 8000

**Build Errors**
```bash
flutter clean
flutter pub get
flutter run
```

### Admin Dashboard Issues

**Port already in use**
```bash
# Change port in vite.config.ts
server: { port: 3001 }
```

**API Connection Failed**
- Check `.env` file has correct API URL
- Ensure backend is running
- Check CORS settings in backend

**Module not found**
```bash
rm -rf node_modules package-lock.json
npm install
```

## 📚 Resources

- **Flutter Docs**: https://flutter.dev/docs
- **React Docs**: https://react.dev
- **API Docs**: http://127.0.0.1:8000/docs

## 🚀 Next Steps

1. Set up development environment (Flutter/Node.js)
2. Install dependencies
3. Configure API endpoints
4. Run development servers
5. Start building features!

---

**Ready to build amazing frontends! 🎨**
