import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/client.dart';

// Configure API base URL
// For Android Emulator: use 'http://10.0.2.2:8000/v1'
// For Physical Android Device: use your computer's IP address
// Find your IP: ifconfig | grep "inet " | grep -v 127.0.0.1
// Example: 'http://10.73.50.47:8000/v1' (replace with your actual IP)
final apiClientProvider = Provider((ref) => TalkamApiClient(
  // Koyeb production URL
  baseUrl: 'https://little-amity-talkam-c84a1504.koyeb.app/v1',  // Koyeb production URL
));
