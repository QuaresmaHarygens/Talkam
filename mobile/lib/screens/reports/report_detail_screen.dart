import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers.dart';
import '../../models/report.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  
  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Report? _report;
  bool _loading = true;
  bool _hasNotification = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.getReport(widget.reportId);
      
      // Check if user has a notification for this report
      bool hasNotification = false;
      try {
        final notifications = await client.getNotifications();
        hasNotification = notifications.any((n) => 
          n['report_id'] == widget.reportId && 
          (n['read'] == false || n['action_taken'] == false)
        );
      } catch (_) {
        // Ignore notification check errors
      }
      
      setState(() {
        _report = Report.fromJson(data);
        _hasNotification = hasNotification;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Details')),
        body: const Center(child: Text('Report not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details.'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          if (_hasNotification)
            IconButton(
              icon: const Badge(
                label: Text('!'),
                child: Icon(Icons.notifications_active),
              ),
              tooltip: 'Attestation Request',
              onPressed: () => _showAttestationDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Report Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _report!.summary,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_report!.verificationScore != null &&
                    _report!.verificationScore! > 0.8)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Chip(
                      label: const Text('Verified'),
                      backgroundColor: Colors.green.shade100,
                      labelStyle: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          // Map View
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Map View\n${_report!.location.latitude}, ${_report!.location.longitude}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tabs: Thread/Comments matching wireframe
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0F172A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0F172A),
            tabs: const [
              Tab(text: 'Thread'),
              Tab(text: 'Comments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Thread Tab - Show Timeline
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_report!.details != null) ...[
                      Text(
                        'Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _report!.details!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Timeline',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_report!.timeline != null && _report!.timeline!.isNotEmpty)
                      ..._report!.timeline!.map((event) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getTimelineColor(event.type),
                                child: Icon(
                                  _getTimelineIcon(event.type),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(event.description),
                              subtitle: Text(
                                '${_formatTimestamp(event.timestamp)}${event.actor != null ? ' • ${event.actor}' : ''}',
                              ),
                            ),
                          ))
                    else
                      Column(children: _buildTimelineFromReport()),
                  ],
                ),
                // Comments Tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('No comments yet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineFromReport() {
    final events = <Widget>[];
    
    // Created event
    events.add(Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
        title: const Text('Report Created'),
        subtitle: Text(_formatTimestamp(_report!.createdAt)),
      ),
    ));

    // Status changes
    if (_report!.updatedAt != null && _report!.updatedAt != _report!.createdAt) {
      events.add(Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(_report!.status),
            child: Icon(
              _getStatusIcon(_report!.status),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text('Status: ${_report!.status}'),
          subtitle: Text(_formatTimestamp(_report!.updatedAt!)),
        ),
      ));
    }

    // Assignment
    if (_report!.assignedAgency != null) {
      events.add(Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.assignment, color: Colors.white, size: 20),
          ),
          title: Text('Assigned to ${_report!.assignedAgency}'),
          subtitle: Text(_formatTimestamp(_report!.updatedAt ?? _report!.createdAt)),
        ),
      ));
    }

    // Verification
    if (_report!.verificationScore != null && _report!.verificationScore! > 0.8) {
      events.add(Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.verified, color: Colors.white, size: 20),
          ),
          title: Text('Verified (Score: ${(_report!.verificationScore! * 100).toStringAsFixed(0)}%)'),
          subtitle: Text(_formatTimestamp(_report!.updatedAt ?? _report!.createdAt)),
        ),
      ));
    }

    return events.isEmpty
        ? [const Center(child: Text('No timeline events'))]
        : events;
  }

  Color _getTimelineColor(String type) {
    switch (type) {
      case 'created':
        return Colors.blue;
      case 'verified':
        return Colors.green;
      case 'assigned':
        return Colors.orange;
      case 'status_changed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimelineIcon(String type) {
    switch (type) {
      case 'created':
        return Icons.add;
      case 'verified':
        return Icons.verified;
      case 'assigned':
        return Icons.assignment;
      case 'status_changed':
        return Icons.update;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under-review':
        return Colors.orange;
      case 'resolved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'under-review':
        return Icons.hourglass_empty;
      case 'resolved':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _showAttestationDialog(BuildContext context) async {
    String? selectedAction;
    String? selectedConfidence;
    final commentController = TextEditingController();
    bool includeLocation = false;
    double? userLat;
    double? userLon;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Attest to Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How would you like to respond?'),
                const SizedBox(height: 16),
                // Action selection
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'confirm', label: Text('Confirm')),
                    ButtonSegment(value: 'deny', label: Text('Deny')),
                    ButtonSegment(value: 'needs_info', label: Text('Need Info')),
                  ],
                  selected: selectedAction != null ? {selectedAction!} : {},
                  onSelectionChanged: (Set<String> newSelection) {
                    setDialogState(() => selectedAction = newSelection.first);
                  },
                ),
                const SizedBox(height: 16),
                // Confidence selection
                if (selectedAction == 'confirm')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Confidence Level:'),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'high', label: Text('High')),
                          ButtonSegment(value: 'medium', label: Text('Medium')),
                          ButtonSegment(value: 'low', label: Text('Low')),
                        ],
                        selected: selectedConfidence != null ? {selectedConfidence!} : {},
                        onSelectionChanged: (Set<String> newSelection) {
                          setDialogState(() => selectedConfidence = newSelection.first);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Comment
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'Add any additional information...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Location checkbox
                CheckboxListTile(
                  title: const Text('Include my location'),
                  subtitle: const Text('Help verify proximity to report'),
                  value: includeLocation,
                  onChanged: (value) {
                    setDialogState(() => includeLocation = value ?? false);
                    if (includeLocation) {
                      _getCurrentLocation().then((position) {
                        if (position != null) {
                          setDialogState(() {
                            userLat = position.latitude;
                            userLon = position.longitude;
                          });
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedAction != null
                  ? () => Navigator.pop(context, {
                        'action': selectedAction,
                        'confidence': selectedConfidence,
                        'comment': commentController.text.isEmpty
                            ? null
                            : commentController.text,
                        'latitude': userLat,
                        'longitude': userLon,
                      })
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    if (result != null && _report != null) {
      try {
        final client = ref.read(apiClientProvider);
        await client.attestToReport(
          reportId: _report!.id,
          action: result['action'] as String,
          confidence: result['confidence'] as String?,
          comment: result['comment'] as String?,
          latitude: result['latitude'] as double?,
          longitude: result['longitude'] as double?,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your attestation!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _hasNotification = false);
          _loadReport(); // Refresh to show updated witness count
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting attestation: $e')),
          );
        }
      }
    }
  }

  Future<dynamic> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return null;
    }
  }
}
