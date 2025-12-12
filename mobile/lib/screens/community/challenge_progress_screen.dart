import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/challenge.dart';
import '../../providers.dart';

class ChallengeProgressScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeProgressScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeProgressScreen> createState() => _ChallengeProgressScreenState();
}

class _ChallengeProgressScreenState extends ConsumerState<ChallengeProgressScreen> {
  List<ChallengeProgressUpdate> _progressUpdates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressUpdates();
  }

  Future<void> _loadProgressUpdates() async {
    try {
      setState(() => _loading = true);
      final client = ref.read(apiClientProvider);
      final progressData = await client.getChallengeProgress(widget.challengeId);
      setState(() {
        _progressUpdates = progressData
            .map((p) => ChallengeProgressUpdate.fromJson(p))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading progress: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Updates'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _progressUpdates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No progress updates yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProgressUpdates,
                  child: ListView.builder(
                    itemCount: _progressUpdates.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final update = _progressUpdates[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getProgressColor(update.progressPercentage).withOpacity(0.2),
                                    child: Text(
                                      '${update.progressPercentage.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: _getProgressColor(update.progressPercentage),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          update.userName ?? 'User',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(update.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (update.milestone != null)
                                    Chip(
                                      label: Text(update.milestone!),
                                      backgroundColor: Colors.green.shade100,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(update.description),
                              if (update.mediaUrls.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: update.mediaUrls.length,
                                    itemBuilder: (context, i) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            update.mediaUrls[i],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.broken_image),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.blue;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

