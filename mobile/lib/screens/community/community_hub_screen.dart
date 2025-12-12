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
  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];
  bool _loading = true;
  String _selectedFilter = 'active'; // 'active' or 'completed'
  String? _selectedCategory;
  Position? _currentPosition;
  int _outstandingCount = 0;
  int _userPoints = 0;
  double _userBalance = 0.0;

  final Map<String, String> _categories = {
    'all': 'All Challenges',
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
        status: _selectedFilter,
      );

      final challengesList = (response['challenges'] as List)
          .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
          .toList();

      // Separate active and completed
      final active = challengesList.where((c) => c.status == 'active').toList();
      final completed = challengesList.where((c) => c.status == 'completed').toList();

      // Calculate outstanding (expiring soon)
      final now = DateTime.now();
      _outstandingCount = active.where((c) {
        if (c.expiresAt == null) return false;
        final daysUntilExpiry = c.expiresAt!.difference(now).inDays;
        return daysUntilExpiry <= 20 && daysUntilExpiry > 0;
      }).length;

      setState(() {
        _challenges = challengesList;
        _activeChallenges = active;
        _completedChallenges = completed;
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

  int _calculatePoints(Challenge challenge) {
    // Calculate points based on participation and progress
    int basePoints = challenge.participantsCount * 10;
    int progressPoints = (challenge.progressPercentage / 10).round() * 5;
    return basePoints + progressPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigation(),
            
            // Outstanding Challenges Banner
            if (_outstandingCount > 0) ...[
              _buildOutstandingBanner(),
              if (_outstandingCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'EXPIRING IN 20 DAYS',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            
            // Your Summary Section
            _buildSummarySection(),
            
            // Active/Completed Tabs
            _buildFilterTabs(),
            
            // Category Cards
            _buildCategoryCards(),
            
            // Challenges List
            Expanded(
              child: _buildChallengesList(),
            ),
            
            // Our Badges Section
            _buildBadgesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateChallengeScreen(),
            ),
          ).then((_) => _loadChallenges());
        },
        backgroundColor: const Color(0xFFE91E63), // Hot pink
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR BADGES',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Use LayoutBuilder to make badges responsive
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate badge width based on available space
              final badgeWidth = (constraints.maxWidth - 24) / 3; // 3 badges with 12px spacing
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBadgeCard(
                    icon: Icons.star,
                    label: 'LEADER',
                    color: const Color(0xFFE91E63),
                    width: badgeWidth,
                  ),
                  _buildBadgeCard(
                    icon: Icons.person_add,
                    label: 'NEW USER',
                    color: const Color(0xFFE91E63),
                    width: badgeWidth,
                  ),
                  _buildBadgeCard(
                    icon: Icons.volunteer_activism,
                    label: 'VOLUNTEER',
                    color: const Color(0xFFE91E63),
                    width: badgeWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String label,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63), // Hot pink
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Navigation Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63), // Hot pink
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_outstandingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'OUTSTANDING CHALLENGES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR SUMMARY',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '\$${_userBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BALANCE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              Column(
                children: [
                  Text(
                    _userPoints.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to details
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'SEE DETAILS',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterTab('active', 'ACTIVE', _activeChallenges.length),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterTab('completed', 'COMPLETED', _completedChallenges.length),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label, int count) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = filter);
        _loadChallenges();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1.0,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count items',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _categories.entries.map((entry) {
          final isSelected = _selectedCategory == entry.key || (_selectedCategory == null && entry.key == 'all');
          final isAll = entry.key == 'all';
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = entry.key == 'all' ? null : entry.key;
                });
                _loadChallenges();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAll)
                      const Icon(Icons.all_inclusive, color: Colors.white, size: 32)
                    else
                      Icon(
                        _getCategoryIcon(entry.key),
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        size: 32,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_challenges.where((c) => entry.key == 'all' || c.category == entry.key).length} items',
                      style: TextStyle(
                        color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChallengesList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayChallenges = _selectedFilter == 'active' ? _activeChallenges : _completedChallenges;

    if (displayChallenges.isEmpty) {
      return Center(
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
              'No ${_selectedFilter} challenges',
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
          ],
        ),
      );
    }

    // Sort by expiry date (soonest first)
    displayChallenges.sort((a, b) {
      if (a.expiresAt == null && b.expiresAt == null) return 0;
      if (a.expiresAt == null) return 1;
      if (b.expiresAt == null) return -1;
      return a.expiresAt!.compareTo(b.expiresAt!);
    });

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayChallenges.length,
        itemBuilder: (context, index) {
          final challenge = displayChallenges[index];
          final daysUntilExpiry = challenge.expiresAt != null
              ? challenge.expiresAt!.difference(DateTime.now()).inDays
              : null;
          final points = _calculatePoints(challenge);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
                  ),
                ).then((_) => _loadChallenges());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Category Icon (circular with icon)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(challenge.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(challenge.category),
                        color: _getCategoryColor(challenge.category),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Challenge Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (daysUntilExpiry != null && daysUntilExpiry > 0)
                            Text(
                              'EXPIRES IN $daysUntilExpiry ${daysUntilExpiry == 1 ? 'DAY' : 'DAYS'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: daysUntilExpiry <= 5
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            )
                          else if (challenge.status == 'completed')
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          if (challenge.progressPercentage < 100 && challenge.status == 'active')
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'SUBMISSION UNDER REVIEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Points Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$points\npoints',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.people;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'environmental':
        return Icons.eco;
      case 'security':
        return Icons.security;
      case 'religious':
        return Icons.church;
      case 'infrastructure':
        return Icons.build;
      case 'economic':
        return Icons.attach_money;
      default:
        return Icons.flag;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Colors.blue;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.purple;
      case 'environmental':
        return Colors.green;
      case 'security':
        return Colors.orange;
      case 'religious':
        return Colors.indigo;
      case 'infrastructure':
        return Colors.brown;
      case 'economic':
        return Colors.teal;
      default:
        return const Color(0xFFE91E63);
    }
  }
}

