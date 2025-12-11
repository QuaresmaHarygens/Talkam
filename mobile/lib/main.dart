import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'services/offline_storage.dart';
import 'services/sync_service.dart';
import 'providers.dart';

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
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFF59E0B), // Sunrise Amber
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Cotton Grey
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: const WelcomeScreen(), // Start with welcome/onboarding
      debugShowCheckedModeBanner: false,
    );
  }
}
