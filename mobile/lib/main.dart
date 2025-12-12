import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'services/offline_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineStorageService().init();
  
  // Initialize sync service for periodic syncing
  final app = const ProviderScope(child: TalkamApp());
  runApp(app);
  
  // Start background sync (will be initialized after ProviderScope)
  // Note: In production, use a proper background service
}

class TalkamApp extends StatelessWidget {
  const TalkamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talkam Liberia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1F4DD8), // Deep Blue (matching web frontend)
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter', // Matching web frontend
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F4DD8), // Deep Blue
          primary: const Color(0xFF1F4DD8),
          secondary: const Color(0xFF1ABF7E), // Emerald
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F4DD8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const WelcomeScreen(), // Start with welcome/onboarding
      debugShowCheckedModeBanner: false,
    );
  }
}
