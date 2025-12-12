/// Models for Community Challenge module
class Challenge {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String? county;
  final String? district;
  final Map<String, dynamic> neededResources;
  final String urgencyLevel;
  final int? durationDays;
  final String? expectedImpact;
  final String status;
  final double progressPercentage;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final String? creatorName;
  final int participantsCount;
  final int volunteersCount;
  final int donorsCount;

  Challenge({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.county,
    this.district,
    required this.neededResources,
    required this.urgencyLevel,
    this.durationDays,
    this.expectedImpact,
    required this.status,
    required this.progressPercentage,
    required this.mediaUrls,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.creatorName,
    required this.participantsCount,
    required this.volunteersCount,
    required this.donorsCount,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      county: json['county'] as String?,
      district: json['district'] as String?,
      neededResources: json['needed_resources'] as Map<String, dynamic>? ?? {},
      urgencyLevel: json['urgency_level'] as String? ?? 'medium',
      durationDays: json['duration_days'] as int?,
      expectedImpact: json['expected_impact'] as String?,
      status: json['status'] as String? ?? 'active',
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      creatorName: json['creator_name'] as String?,
      participantsCount: json['participants_count'] as int? ?? 0,
      volunteersCount: json['volunteers_count'] as int? ?? 0,
      donorsCount: json['donors_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'county': county,
      'district': district,
      'needed_resources': neededResources,
      'urgency_level': urgencyLevel,
      'duration_days': durationDays,
      'expected_impact': expectedImpact,
      'status': status,
      'progress_percentage': progressPercentage,
      'media_urls': mediaUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'creator_name': creatorName,
      'participants_count': participantsCount,
      'volunteers_count': volunteersCount,
      'donors_count': donorsCount,
    };
  }
}

class ChallengeProgressUpdate {
  final String id;
  final String challengeId;
  final String userId;
  final String description;
  final List<String> mediaUrls;
  final double progressPercentage;
  final String? milestone;
  final DateTime createdAt;
  final String? userName;

  ChallengeProgressUpdate({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.description,
    required this.mediaUrls,
    required this.progressPercentage,
    this.milestone,
    required this.createdAt,
    this.userName,
  });

  factory ChallengeProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressUpdate(
      id: json['id'] as String,
      challengeId: json['challenge_id'] as String,
      userId: json['user_id'] as String,
      description: json['description'] as String,
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      milestone: json['milestone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String?,
    );
  }
}

class ChallengeParticipation {
  final String id;
  final String userId;
  final String challengeId;
  final String role; // participant, volunteer, donor, organizer
  final Map<String, dynamic> contributionDetails;
  final DateTime createdAt;
  final String? userName;

  ChallengeParticipation({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.role,
    required this.contributionDetails,
    required this.createdAt,
    this.userName,
  });

  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      role: json['role'] as String,
      contributionDetails: json['contribution_details'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String?,
    );
  }
}

