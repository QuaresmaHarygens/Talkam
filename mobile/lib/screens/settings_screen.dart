import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/offline_storage.dart';
import '../services/sync_service.dart';
import '../providers.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _offlineQueueSize = 0;

  @override
  void initState() {
    super.initState();
    _loadQueueSize();
  }

  void _loadQueueSize() {
    final storage = OfflineStorageService();
    setState(() => _offlineQueueSize = storage.queueSize);
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _syncNow() async {
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.syncQueuedReports();
      _loadQueueSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  Future<void> _clearOfflineQueue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Offline Queue?'),
        content: const Text('This will delete all queued reports that haven\'t been synced.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = OfflineStorageService();
      await storage.clearQueue();
      _loadQueueSize();
    }
  }

  void _logout() {
    ref.read(apiClientProvider).clearToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Sync Now'),
            subtitle: Text('$_offlineQueueSize reports queued'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _syncNow,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Offline Queue'),
            subtitle: const Text('Delete unsynced reports'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _clearOfflineQueue,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete my reports'),
            subtitle: const Text('Permanently delete all your reports'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete All Reports?'),
                  content: const Text(
                    'This will permanently delete all your reports. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete All'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  final client = ref.read(apiClientProvider);
                  final result = await client.deleteAllReports();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] as String? ??
                              'Reports deleted successfully',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting reports: $e')),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permissions'),
            subtitle: const Text('Location, Camera, Microphone'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _requestPermissions,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Two-factor authentication'),
            subtitle: const Text('Add an extra layer of security'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement 2FA
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Two-Factor Authentication'),
                  content: const Text('Two-factor authentication feature coming soon.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Offline data'),
            subtitle: Text('$_offlineQueueSize reports queued'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Offline Data'),
                  content: Text('$_offlineQueueSize reports are queued for sync.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Emergency hotlines'),
            subtitle: const Text('View emergency contacts'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Emergency Hotlines'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Police: 911'),
                      Text('Fire: 911'),
                      Text('Medical: 911'),
                      SizedBox(height: 8),
                      Text('SAMPLE DATA - Update with real numbers'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Talkam Liberia v0.1.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Talkam Liberia',
                applicationVersion: '0.1.0',
                applicationLegalese: 'Safe voices, fast response',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
