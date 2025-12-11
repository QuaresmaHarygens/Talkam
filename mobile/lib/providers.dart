import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/client.dart';

// Configure API base URL
// For Android Emulator: use 'http://10.0.2.2:8000/v1'
// For Physical Android Device: use your computer's IP address
// Find your IP: ifconfig | grep "inet " | grep -v 127.0.0.1
// Example: 'http://10.73.50.47:8000/v1' (replace with your actual IP)
final apiClientProvider = Provider((ref) => TalkamApiClient(
  // Fly.io production URL
  baseUrl: 'https://talkam-backend-7653.fly.dev/v1',  // Fly.io production URL
));
