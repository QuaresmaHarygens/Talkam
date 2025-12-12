import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../utils/connectivity_helper.dart';
import 'create_report_screen.dart';
import 'map_screen.dart';
import 'community/community_hub_screen.dart';
import 'reports/report_detail_screen.dart';
import '../models/report.dart';

/// Enhanced Dashboard matching web frontend design
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<Report> _reports = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      // Check connectivity first
      final hasConnection = await ConnectivityHelper.hasInternetConnection();
      if (!hasConnection) {
        setState(() {
          _loading = false;
          _errorMessage = 'No internet connection. Please check your network settings.';
        });
        return;
      }

      final client = ref.read(apiClientProvider);
      final response = await client.searchReports();
      final results = (response['results'] as List)
          .map((r) => Report.fromJson(r as Map<String, dynamic>))
          .toList();
      setState(() {
        _reports = results;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load reports. ${e.toString().contains('SocketException') || e.toString().contains('connection') ? 'Please check your connection and try again.' : 'Please try again later.'}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadReports,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.foreground,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              label: 'New Report',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateReportScreen(),
                  ),
                );
              },
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            Text(
              "Welcome back! Here's what's happening in your community.",
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacing24),

            // 4 Main Action Cards (matching web frontend)
            _buildActionCards(),

            const SizedBox(height: AppTheme.spacing24),

            // Error Message
            if (_errorMessage != null && !_loading)
              AppCard(
                backgroundColor: Colors.red.shade50,
                margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTheme.bodySmall.copyWith(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadReports,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Recent Reports Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reports',
                  style: AppTheme.heading3,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all reports
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Recent Reports List
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? _buildEmptyState()
                    : _buildRecentReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacing16,
      crossAxisSpacing: AppTheme.spacing16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          icon: Icons.description,
          title: 'Report Issue',
          subtitle: 'Submit a new civic issue',
          color: AppTheme.primary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateReportScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.check_circle,
          title: 'Verify Reports',
          subtitle: 'Help verify community reports',
          color: AppTheme.secondary,
          onTap: () {
            // Navigate to verify
          },
        ),
        _buildActionCard(
          icon: Icons.people,
          title: 'Challenges',
          subtitle: 'Join community challenges',
          color: AppTheme.primary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CommunityHubScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.map,
          title: 'Map View',
          subtitle: 'Explore issues on map',
          color: AppTheme.secondary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MapScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppTheme.mutedForeground,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.heading3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_reports.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppTheme.mutedForeground,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'No reports yet',
              style: AppTheme.heading3.copyWith(color: AppTheme.mutedForeground),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Be the first to report an issue in your community',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _reports.take(5).map((report) {
        return AppCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(reportId: report.id),
              ),
            );
          },
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.summary,
                style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${report.category} • ${report.location.county}',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSeverityChip(report.severity),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(report.createdAt),
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeverityChip(String severity) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.description,
              size: 48,
              color: AppTheme.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to report an issue!',
              style: AppTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
