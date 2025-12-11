// import 'package:device_info_plus/device_info_plus';
// import 'package:package_info_plus/package_info_plus';
// import 'package:firebase_messaging/firebase_messaging.dart';  // Uncomment when Firebase is configured
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../api/client.dart';

/// Service for managing device tokens for push notifications
class DeviceTokenService {
  final TalkamApiClient apiClient;

  DeviceTokenService(this.apiClient);

  /// Register device token with backend
  /// This should be called after user authentication
  Future<bool> registerDeviceToken() async {
    try {
      // Get FCM token (for Android/iOS)
      String? fcmToken;
      String platform = 'web';

      if (!kIsWeb) {
        if (Platform.isAndroid) {
          platform = 'android';
          // Try to get FCM token if Firebase is configured
          // Uncomment when Firebase is set up:
          // try {
          //   fcmToken = await FirebaseMessaging.instance.getToken();
          // } catch (e) {
          //   fcmToken = 'android_token_${DateTime.now().millisecondsSinceEpoch}';
          // }
          // For now, use placeholder token
          fcmToken = 'android_token_${DateTime.now().millisecondsSinceEpoch}';
        } else if (Platform.isIOS) {
          platform = 'ios';
          // Try to get APNs token if Firebase is configured
          // Uncomment when Firebase is set up:
          // try {
          //   fcmToken = await FirebaseMessaging.instance.getToken();
          // } catch (e) {
          //   fcmToken = 'ios_token_${DateTime.now().millisecondsSinceEpoch}';
          // }
          // For now, use placeholder token
          fcmToken = 'ios_token_${DateTime.now().millisecondsSinceEpoch}';
        }
      } else {
        platform = 'web';
        // Web push tokens would be handled differently
        fcmToken = 'web_token_${DateTime.now().millisecondsSinceEpoch}';
      }

      if (fcmToken == null) {
        debugPrint('⚠️ Could not get device token');
        return false;
      }

      // Get app version
      String? appVersion = '1.0.0';
      // TODO: Uncomment when package_info_plus is properly installed
      // try {
      //   final packageInfo = await PackageInfo.fromPlatform();
      //   appVersion = packageInfo.version;
      // } catch (e) {
      //   appVersion = '1.0.0';
      // }

      // Get device info
      String? deviceInfo = 'Unknown Device';
      // TODO: Uncomment when device_info_plus is properly installed
      // try {
      //   final deviceInfoPlugin = DeviceInfoPlugin();
      //   if (Platform.isAndroid) {
      //     final androidInfo = await deviceInfoPlugin.androidInfo;
      //     deviceInfo = '${androidInfo.brand} ${androidInfo.model}, Android ${androidInfo.version.release}';
      //   } else if (Platform.isIOS) {
      //     final iosInfo = await deviceInfoPlugin.iosInfo;
      //     deviceInfo = '${iosInfo.model}, iOS ${iosInfo.systemVersion}';
      //   }
      // } catch (e) {
      //   deviceInfo = 'Unknown Device';
      // }

      // Register with backend
      await apiClient.registerDeviceToken(
        token: fcmToken,
        platform: platform,
        appVersion: appVersion,
        deviceInfo: deviceInfo,
      );

      debugPrint('✅ Device token registered: $platform');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to register device token: $e');
      return false;
    }
  }

  /// Unregister device token (on logout)
  Future<void> unregisterDeviceToken(String tokenId) async {
    try {
      await apiClient.unregisterDeviceToken(tokenId);
      debugPrint('✅ Device token unregistered');
    } catch (e) {
      debugPrint('❌ Failed to unregister device token: $e');
    }
  }
}
