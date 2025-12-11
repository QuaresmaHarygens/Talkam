import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../providers.dart';
import 'reports/report_detail_screen.dart';

class ReportsFeedScreen extends ConsumerStatefulWidget {
  const ReportsFeedScreen({super.key});

  @override
  ConsumerState<ReportsFeedScreen> createState() => _ReportsFeedScreenState();
}

class _ReportsFeedScreenState extends ConsumerState<ReportsFeedScreen> {
  List<Report> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.searchReports();
      final results = (response['results'] as List)
          .map((r) => Report.fromJson(r as Map<String, dynamic>))
          .toList();
      setState(() {
        _reports = results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Text('No reports yet. Be the first to report!'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        itemCount: _reports.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(report.summary),
              subtitle: Text('${report.category} • ${report.location.county} • ${report.status}'),
              trailing: _getSeverityChip(report.severity),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(reportId: report.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getSeverityChip(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'critical':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.yellow;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(severity.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontSize: 10),
    );
  }
}
