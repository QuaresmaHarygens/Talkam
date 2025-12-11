import 'package:hive_flutter/hive_flutter.dart';
import '../models/report.dart';

class OfflineStorageService {
  static const String _reportsBoxName = 'offline_reports';
  static const int _maxQueueSize = 50;

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_reportsBoxName);
  }

  Box<Map> get _reportsBox => Hive.box<Map>(_reportsBoxName);

  Future<void> queueReport(Map<String, dynamic> reportData) async {
    final box = _reportsBox;
    if (box.length >= _maxQueueSize) {
      // Remove oldest entry
      final keys = box.keys.toList()..sort();
      await box.delete(keys.first);
    }
    await box.put(DateTime.now().millisecondsSinceEpoch.toString(), reportData);
  }

  List<Map<String, dynamic>> getQueuedReports() {
    return _reportsBox.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<void> removeQueuedReport(String key) async {
    await _reportsBox.delete(key);
  }

  Future<void> clearQueue() async {
    await _reportsBox.clear();
  }

  int get queueSize => _reportsBox.length;
}
