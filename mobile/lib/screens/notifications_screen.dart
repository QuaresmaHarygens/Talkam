import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'reports/report_detail_screen.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final client = ref.read(apiClientProvider);
      final notifications = await client.getNotifications();
      final unreadData = await client.getUnreadCount();
      
      setState(() {
        _notifications = notifications;
        _unreadCount = unreadData['unread_count'] as int? ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.markNotificationRead(notificationId);
      
      setState(() {
        _notifications[index]['read'] = true;
        if (_unreadCount > 0) _unreadCount--;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking as read: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Badge(
                  label: Text('$_unreadCount'),
                  child: const Icon(Icons.notifications),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ll see attestation requests here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['read'] as bool? ?? false;
                      final actionTaken = notification['action_taken'] as bool? ?? false;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isRead ? null : Colors.blue.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: actionTaken
                                ? Colors.green
                                : isRead
                                    ? Colors.grey
                                    : Colors.blue,
                            child: Icon(
                              actionTaken
                                  ? Icons.check
                                  : Icons.notifications_active,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notification['title'] as String? ?? 'Notification',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message'] as String? ?? ''),
                              if (notification['report_category'] != null)
                                Text(
                                  '${notification['report_category']} • ${notification['report_severity']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          trailing: actionTaken
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () async {
                            if (!isRead) {
                              await _markAsRead(
                                notification['id'] as String,
                                index,
                              );
                            }
                            
                            // Navigate to report detail
                            final reportId = notification['report_id'] as String?;
                            if (reportId != null && mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReportDetailScreen(reportId: reportId),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
