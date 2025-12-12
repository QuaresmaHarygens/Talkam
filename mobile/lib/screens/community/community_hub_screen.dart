import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/challenge.dart';
import '../../providers.dart';
import 'create_challenge_screen.dart';
import 'challenge_detail_screen.dart';

class CommunityHubScreen extends ConsumerStatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  ConsumerState<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends ConsumerState<CommunityHubScreen> {
  List<Challenge> _challenges = [];
  bool _loading = true;
  String? _selectedCategory;
  Position? _currentPosition;

  final Map<String, String> _categories = {
    'all': 'All',
    'social': 'Social',
    'health': 'Health',
    'education': 'Education',
    'environmental': 'Environmental',
    'security': 'Security',
    'religious': 'Religious',
    'infrastructure': 'Infrastructure',
    'economic': 'Economic',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      _loadChallenges();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _loadChallenges() async {
    if (_currentPosition == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      setState(() => _loading = true);
      final client = ref.read(apiClientProvider);
      final response = await client.listChallenges(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 5.0,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );

      final challengesList = (response['challenges'] as List)
          .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
          .toList();

      setState(() {
        _challenges = challengesList;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading challenges: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateChallengeScreen(),
                ),
              ).then((_) => _loadChallenges());
            },
            tooltip: 'Create Challenge',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _categories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key || (_selectedCategory == null && entry.key == 'all');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = entry.key == 'all' ? null : entry.key;
                      });
                      _loadChallenges();
                    },
                    selectedColor: Colors.orange.shade100,
                    checkmarkColor: Colors.orange,
                  ),
                );
              }).toList(),
            ),
          ),
          // Challenges list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _challenges.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No challenges nearby',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create the first challenge in your community!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CreateChallengeScreen(),
                                  ),
                                ).then((_) => _loadChallenges());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Challenge'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadChallenges,
                        child: ListView.builder(
                          itemCount: _challenges.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final challenge = _challenges[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
                                    ),
                                  ).then((_) => _loadChallenges());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              challenge.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _getUrgencyChip(challenge.urgencyLevel),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        challenge.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            challenge.county ?? 'Unknown location',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${challenge.participantsCount}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(Icons.volunteer_activism, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${challenge.volunteersCount}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: challenge.progressPercentage / 100,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _getProgressColor(challenge.progressPercentage),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${challenge.progressPercentage.toStringAsFixed(0)}% Complete',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
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
}
