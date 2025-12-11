import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../reports/report_detail_screen.dart';

class NGODashboardScreen extends ConsumerStatefulWidget {
  const NGODashboardScreen({super.key});

  @override
  ConsumerState<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends ConsumerState<NGODashboardScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.searchReports(status: 'submitted');
      setState(() {
        _reports = (data['results'] as List?)
                ?.map((r) => r as Map<String, dynamic>)
                .toList() ??
            [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard.'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No reports available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['summary'] as String? ?? 'No summary',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Request Info button
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Request info feature coming soon')),
                                    );
                                  },
                                  icon: const Icon(Icons.info_outline, size: 18),
                                  label: const Text('Request Info'),
                                ),
                                // Assign button
                                OutlinedButton.icon(
                                  onPressed: () => _assignReport(context, report),
                                  icon: const Icon(Icons.assignment, size: 18),
                                  label: const Text('Assign'),
                                ),
                                // Clock icon (timeline/history)
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ReportDetailScreen(
                                          reportId: report['id'] as String,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.access_time),
                                  tooltip: 'View Timeline',
                                ),
                                // Bell icon (notifications/subscribe)
                                IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Subscribed to updates for this report'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.notifications_outlined),
                                  tooltip: 'Subscribe to Updates',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _assignReport(BuildContext context, Map<String, dynamic> report) async {
    final agencyController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Report'),
        content: TextField(
          controller: agencyController,
          decoration: const InputDecoration(
            labelText: 'Agency/NGO Name',
            hintText: 'Enter agency name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (agencyController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'agency': agencyController.text,
                });
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final client = ref.read(apiClientProvider);
        await client.assignReport(
          reportId: report['id'] as String,
          agency: result['agency']!,
          status: 'assigned',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report assigned successfully')),
          );
          _loadReports(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment failed: $e')),
          );
        }
      }
    }
  }
}
