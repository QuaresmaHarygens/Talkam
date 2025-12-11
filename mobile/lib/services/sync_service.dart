import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/client.dart';
import '../providers.dart';
import 'offline_storage.dart';

class SyncService {
  final TalkamApiClient _apiClient;
  final OfflineStorageService _offlineStorage;

  SyncService(this._apiClient, this._offlineStorage);

  Future<void> syncQueuedReports() async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // No connectivity, skip sync
    }

    final queuedReports = _offlineStorage.getQueuedReports();
    if (queuedReports.isEmpty) return;

    final syncedIds = <String>[];

    for (final reportData in queuedReports) {
      try {
        await _apiClient.createReport(
          category: reportData['category'] as String,
          severity: reportData['severity'] as String,
          summary: reportData['summary'] as String,
          details: reportData['details'] as String?,
          location: reportData['location'] as Map<String, dynamic>,
          media: (reportData['media'] as List<dynamic>?)
                  ?.map((m) => m as Map<String, dynamic>)
                  .toList() ??
              [],
          anonymous: reportData['anonymous'] as bool? ?? false,
        );

        // Mark as synced
        final key = reportData['offline_reference'] as String?;
        if (key != null) {
          syncedIds.add(key);
          await _offlineStorage.removeQueuedReport(key);
        }
      } catch (e) {
        // Keep in queue if sync fails
        continue;
      }
    }

    // Confirm sync with backend
    if (syncedIds.isNotEmpty) {
      try {
        await _apiClient.syncOfflineReports(offlineReferences: syncedIds);
      } catch (e) {
        // Log error but don't fail
      }
    }
  }

  Future<void> startPeriodicSync() async {
    // Sync every 5 minutes when online
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncQueuedReports();
      }
    });
  }
}

final syncServiceProvider = Provider((ref) {
  final apiClient = ref.read(apiClientProvider);
  final offlineStorage = OfflineStorageService();
  return SyncService(apiClient, offlineStorage);
});
