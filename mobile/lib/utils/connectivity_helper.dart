import 'package:connectivity_plus/connectivity_plus.dart';

/// Helper class for checking network connectivity
class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Get current connectivity status
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Stream of connectivity changes
  static Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  /// Check if connected via WiFi
  static Future<bool> isConnectedViaWiFi() async {
    final result = await getConnectivityStatus();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  static Future<bool> isConnectedViaMobile() async {
    final result = await getConnectivityStatus();
    return result == ConnectivityResult.mobile;
  }
}
