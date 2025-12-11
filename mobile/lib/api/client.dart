import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'dart:io' show Platform;

class TalkamApiClient {
  late final Dio _dio;
  String? _accessToken;

  TalkamApiClient({String? baseUrl}) {
    // Use 10.0.2.2 for Android emulator (maps to host's 127.0.0.1)
    // Use 127.0.0.1 for iOS simulator, macOS, and web
    final isAndroid = !kIsWeb && (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android);
    final defaultUrl = isAndroid
        ? 'http://10.0.2.2:8000/v1'
        : 'http://127.0.0.1:8000/v1';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? defaultUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.response?.statusCode} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({
    required String fullName,
    String? phone,
    String? email,
    required String password,
    String language = 'en-LR',
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'language': language,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? deviceId,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
      'device_id': deviceId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> anonymousStart({
    required String deviceHash,
    String? county,
    List<String> capabilities = const [],
  }) async {
    final response = await _dio.post('/auth/anonymous-start', data: {
      'device_hash': deviceHash,
      'county': county,
      'capabilities': capabilities,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword({
    String? phone,
    String? email,
  }) async {
    final response = await _dio.post('/auth/forgot-password', data: {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _dio.post('/auth/reset-password', data: {
      'token': token,
      'new_password': newPassword,
    });
    return response.data;
  }

  // Report endpoints
  Future<Map<String, dynamic>> createReport({
    required String category,
    required String severity,
    required String summary,
    String? details,
    required Map<String, dynamic> location,
    List<Map<String, dynamic>>? media,
    bool anonymous = false,
    int? witnessCount,
  }) async {
    final response = await _dio.post('/reports/create', data: {
      'category': category,
      'severity': severity,
      'summary': summary,
      'details': details,
      'location': location,
      'media': media ?? [],
      'anonymous': anonymous,
      'witness_count': witnessCount,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getReport(String reportId) async {
    final response = await _dio.get('/reports/$reportId');
    return response.data;
  }

  Future<Map<String, dynamic>> searchReports({
    String? county,
    String? category,
    String? status,
    String? severity,
    String? text,
    int? page,
    int? pageSize,
  }) async {
    final response = await _dio.get('/reports/search', queryParameters: {
      if (county != null) 'county': county,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (text != null) 'text': text,
      if (page != null) 'page': page,
      if (pageSize != null) 'page_size': pageSize,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> assignReport({
    required String reportId,
    required String agency,
    String? status,
    String? note,
  }) async {
    final response = await _dio.post('/reports/$reportId/assign', data: {
      'agency': agency,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateReportStatus({
    required String reportId,
    required String status,
    String? note,
  }) async {
    final response = await _dio.post('/reports/$reportId/status', data: {
      'status': status,
      if (note != null) 'note': note,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> verifyReport(
    String reportId, {
    required String action,
    String? comment,
    int? witnessCount,
  }) async {
    final response = await _dio.post('/reports/$reportId/verify', data: {
      'action': action,
      'comment': comment,
      'witness_count': witnessCount,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> syncOfflineReports({
    List<String> offlineReferences = const [],
    DateTime? since,
  }) async {
    final response = await _dio.post('/reports/sync', data: {
      'offline_references': offlineReferences,
      'since': since?.toIso8601String(),
    });
    return response.data;
  }

  Future<void> deleteReport(String reportId) async {
    await _dio.delete('/reports/$reportId');
  }

  Future<Map<String, dynamic>> deleteAllReports() async {
    final response = await _dio.delete('/reports/');
    return response.data;
  }

  // Media endpoints
  Future<Map<String, dynamic>> requestUploadUrl({
    required String key,
    required String type,
    String? checksum,
  }) async {
    final response = await _dio.post('/media/upload', data: {
      'key': key,
      'type': type,
      'checksum': checksum,
    });
    return response.data;
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getAnalyticsDashboard() async {
    final response = await _dio.get('/dashboards/analytics');
    return response.data;
  }

  // Notification endpoints
  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
    int? limit,
  }) async {
    final response = await _dio.get('/notifications', queryParameters: {
      if (unreadOnly) 'unread_only': true,
      if (limit != null) 'limit': limit,
    });
    return (response.data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> markNotificationRead(String notificationId) async {
    final response = await _dio.post('/notifications/$notificationId/read');
    return response.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread/count');
    return response.data;
  }

  // Device token management
  Future<Map<String, dynamic>> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
    String? deviceInfo,
  }) async {
    final response = await _dio.post('/device-tokens/register', data: {
      'token': token,
      'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (deviceInfo != null) 'device_info': deviceInfo,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> listDeviceTokens() async {
    final response = await _dio.get('/device-tokens');
    return response.data;
  }

  Future<void> unregisterDeviceToken(String tokenId) async {
    await _dio.delete('/device-tokens/$tokenId');
  }

  // Attestation endpoints
  Future<Map<String, dynamic>> attestToReport({
    required String reportId,
    required String action, // 'confirm', 'deny', 'needs_info'
    String? confidence, // 'high', 'medium', 'low'
    String? comment,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.post('/attestations/reports/$reportId/attest', data: {
      'action': action,
      if (confidence != null) 'confidence': confidence,
      if (comment != null) 'comment': comment,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return response.data;
  }
}
