import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models/report.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  List<Report> _reports = [];
  String? _selectedCategory;
  bool _showHeatmap = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.searchReports(category: _selectedCategory);
      final results = (response['results'] as List)
          .map((r) => Report.fromJson(r as Map<String, dynamic>))
          .toList();
      setState(() => _reports = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading map: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showHeatmap ? Icons.map : Icons.layers),
            onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
            tooltip: 'Toggle Heatmap',
          ),
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() => _selectedCategory = category == 'All' ? null : category);
              _loadReports();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Categories')),
              const PopupMenuItem(value: 'infrastructure', child: Text('Infrastructure')),
              const PopupMenuItem(value: 'security', child: Text('Security')),
              const PopupMenuItem(value: 'health', child: Text('Health')),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const latlng.LatLng(6.4281, -10.7619), // Monrovia
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.talkam.liberia',
          ),
          if (_showHeatmap)
            // Heatmap layer - circles with opacity based on density
            CircleLayer(
              circles: _buildHeatmapCircles(),
            ),
          MarkerLayer(
            markers: _reports
                .where((r) => r.location.latitude != 0 && r.location.longitude != 0)
                .map((report) {
              final color = _getSeverityColor(report.severity);
              return Marker(
                point: latlng.LatLng(
                  report.location.latitude,
                  report.location.longitude,
                ),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showReportDetails(report),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _getCategoryIcon(report.category),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<CircleMarker> _buildHeatmapCircles() {
    // Group reports by location clusters (simple approach)
    final clusters = <String, List<Report>>{};
    
    for (final report in _reports) {
      if (report.location.latitude == 0 && report.location.longitude == 0) {
        continue;
      }
      // Round to 2 decimal places for clustering (~1km precision)
      final key = '${report.location.latitude.toStringAsFixed(2)},${report.location.longitude.toStringAsFixed(2)}';
      clusters.putIfAbsent(key, () => []).add(report);
    }

    final circles = <CircleMarker>[];
    final maxCount = clusters.values.map((r) => r.length).reduce((a, b) => a > b ? a : b);

    clusters.forEach((key, reports) {
      if (reports.isEmpty) return;
      
      final lat = reports.first.location.latitude;
      final lng = reports.first.location.longitude;
      final count = reports.length;
      final intensity = count / (maxCount > 0 ? maxCount : 1);
      
      // Calculate average severity for color
      final avgSeverity = _calculateAverageSeverity(reports);
      final color = _getSeverityColor(avgSeverity);
      
      circles.add(
        CircleMarker(
          point: latlng.LatLng(lat, lng),
          radius: 30 + (intensity * 50), // Radius based on density
          color: color.withOpacity(0.3 * intensity),
          borderColor: color.withOpacity(0.6),
          borderStrokeWidth: 2,
        ),
      );
    });

    return circles;
  }

  String _calculateAverageSeverity(List<Report> reports) {
    int total = 0;
    for (final report in reports) {
      switch (report.severity.toLowerCase()) {
        case 'critical':
          total += 4;
          break;
        case 'high':
          total += 3;
          break;
        case 'medium':
          total += 2;
          break;
        default:
          total += 1;
      }
    }
    final avg = total / reports.length;
    if (avg >= 3.5) return 'critical';
    if (avg >= 2.5) return 'high';
    if (avg >= 1.5) return 'medium';
    return 'low';
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'infrastructure':
        return Icons.route;
      case 'security':
        return Icons.security;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.report;
    }
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.summary,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Category: ${report.category}'),
            Text('Severity: ${report.severity}'),
            Text('Status: ${report.status}'),
            Text('County: ${report.location.county}'),
            if (report.verificationScore != null)
              Text('Verification: ${(report.verificationScore! * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
