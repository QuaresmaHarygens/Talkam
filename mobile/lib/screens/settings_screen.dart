import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/offline_storage.dart';
import '../services/sync_service.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
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

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.mutedForeground,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.foreground,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.foreground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Sync & Offline
          _buildSettingCard(
            icon: Icons.cloud_upload,
            title: 'Sync Now',
            subtitle: '$_offlineQueueSize reports queued',
            onTap: _syncNow,
          ),
          _buildSettingCard(
            icon: Icons.delete_outline,
            title: 'Clear Offline Queue',
            subtitle: 'Delete unsynced reports',
            onTap: _clearOfflineQueue,
          ),
          _buildSettingCard(
            icon: Icons.delete_forever,
            title: 'Delete my reports',
            subtitle: 'Permanently delete all your reports',
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
            iconColor: Colors.red,
          ),
          const SizedBox(height: AppTheme.spacing8),
          // Security & Permissions
          _buildSettingCard(
            icon: Icons.security,
            title: 'Permissions',
            subtitle: 'Location, Camera, Microphone',
            onTap: _requestPermissions,
          ),
          _buildSettingCard(
            icon: Icons.lock,
            title: 'Two-factor authentication',
            subtitle: 'Add an extra layer of security',
            onTap: () {
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
          _buildSettingCard(
            icon: Icons.storage,
            title: 'Offline data',
            subtitle: '$_offlineQueueSize reports queued',
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
          _buildSettingCard(
            icon: Icons.phone,
            title: 'Emergency hotlines',
            subtitle: 'View emergency contacts',
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
          const SizedBox(height: AppTheme.spacing8),
          // About
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Talkam Liberia v0.1.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Talkam Liberia',
                applicationVersion: '0.1.0',
                applicationLegalese: 'Safe voices, fast response',
              );
            },
          ),
          _buildSettingCard(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          const SizedBox(height: AppTheme.spacing8),
          // Logout
          AppCard(
            onTap: _logout,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Logout',
                  style: AppTheme.heading3.copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
