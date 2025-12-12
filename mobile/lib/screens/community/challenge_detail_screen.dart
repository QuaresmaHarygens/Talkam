import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../../models/challenge.dart';
import '../../providers.dart';
import 'challenge_progress_screen.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  Challenge? _challenge;
  List<ChallengeProgressUpdate> _progressUpdates = [];
  List<ChallengeParticipation> _participants = [];
  bool _loading = true;
  bool _hasJoined = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    try {
      setState(() => _loading = true);
      final client = ref.read(apiClientProvider);

      // Load challenge
      final challengeData = await client.getChallenge(widget.challengeId);
      setState(() {
        _challenge = Challenge.fromJson(challengeData);
      });

      // Load progress updates
      final progressData = await client.getChallengeProgress(widget.challengeId);
      setState(() {
        _progressUpdates = progressData
            .map((p) => ChallengeProgressUpdate.fromJson(p))
            .toList();
      });

      // Load participants
      final participantsData = await client.getChallengeParticipants(widget.challengeId);
      setState(() {
        _participants = participantsData
            .map((p) => ChallengeParticipation.fromJson(p))
            .toList();
        // Check if current user has joined
        // TODO: Get current user ID and check
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading challenge: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _joinChallenge(String role) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.joinChallenge(
        challengeId: widget.challengeId,
        role: role,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined challenge!')),
        );
        _loadChallengeDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining challenge: $e')),
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

    if (_challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge Details')),
        body: const Center(child: Text('Challenge not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Details'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0F172A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _challenge!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(_challenge!.category.toUpperCase()),
                        backgroundColor: Colors.orange.shade100,
                      ),
                      const SizedBox(width: 8),
                      _getUrgencyChip(_challenge!.urgencyLevel),
                    ],
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_challenge!.progressPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _challenge!.progressPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(_challenge!.progressPercentage),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _hasJoined
                          ? null
                          : () => _joinChallenge('participant'),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _hasJoined
                          ? null
                          : () => _joinChallenge('volunteer'),
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text('Volunteer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _challenge!.description,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Location map
            if (_challenge!.latitude != 0 && _challenge!.longitude != 0) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: latlng.LatLng(
                        _challenge!.latitude,
                        _challenge!.longitude,
                      ),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.talkam.liberia',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latlng.LatLng(
                              _challenge!.latitude,
                              _challenge!.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    icon: Icons.people,
                    label: 'Participants',
                    value: '${_challenge!.participantsCount}',
                  ),
                  _buildStatCard(
                    icon: Icons.volunteer_activism,
                    label: 'Volunteers',
                    value: '${_challenge!.volunteersCount}',
                  ),
                  _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Donors',
                    value: '${_challenge!.donorsCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress updates
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChallengeProgressScreen(challengeId: widget.challengeId),
                        ),
                      ).then((_) => _loadChallengeDetails());
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            if (_progressUpdates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No progress updates yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _progressUpdates.length > 3 ? 3 : _progressUpdates.length,
                itemBuilder: (context, index) {
                  final update = _progressUpdates[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${update.progressPercentage.toStringAsFixed(0)}%'),
                      ),
                      title: Text(update.description),
                      subtitle: Text(
                        '${update.userName ?? "User"} • ${_formatDate(update.createdAt)}',
                      ),
                      trailing: update.milestone != null
                          ? Chip(
                              label: Text(update.milestone!),
                              backgroundColor: Colors.green.shade100,
                            )
                          : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getUrgencyChip(String urgency) {
    Color color;
    switch (urgency.toLowerCase()) {
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
      label: Text(urgency.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color, fontSize: 10),
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
