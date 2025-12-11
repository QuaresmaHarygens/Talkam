# Talkam Liberia Mobile App

Flutter mobile application for Android and iOS.

## Setup

1. **Install Flutter**
   ```sh
   # macOS
   brew install --cask flutter
   
   # Or download from https://flutter.dev/docs/get-started/install
   ```

2. **Verify installation**
   ```sh
   flutter doctor
   ```

3. **Install dependencies**
   ```sh
   cd mobile
   flutter pub get
   ```

4. **Configure API endpoint**
   Edit `lib/providers.dart` to set your backend URL:
   ```dart
   final apiClientProvider = Provider((ref) => TalkamApiClient(
     baseUrl: 'https://api.talkamliberia.org/v1', // Your backend URL
   ));
   ```

5. **Run the app**
   ```sh
   flutter run
   ```

## Features Implemented

- ✅ API client with authentication
- ✅ Offline report queue (Hive storage)
- ✅ Report creation form with location
- ✅ Reports feed screen
- ✅ Anonymous reporting toggle
- ✅ Offline-first architecture

## Project Structure

```
lib/
  api/          - API client (Dio)
  models/       - Data models (Report, Location, etc.)
  screens/      - UI screens (Home, Create Report, Feed)
  services/     - Business logic (Offline storage, sync)
  providers/    - Riverpod state providers
  widgets/      - Reusable UI components
  utils/        - Utilities
```

## Next Steps

- [ ] Add authentication screens (login/register)
- [ ] Implement map view with heatmap
- [ ] Add media upload (photo/video/audio)
- [ ] Implement offline sync service
- [ ] Add SMS fallback UI
- [ ] Voice recording with masking
- [ ] Settings & help screens
- [ ] Push notifications
- [ ] Localization (Liberian English + local languages)

## Building for Production

### Android
```sh
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```sh
flutter build ios --release
```

## Testing

```sh
flutter test
```
