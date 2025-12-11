class Report {
  final String id;
  final String? reportId; // Public report ID (RPT-YYYY-XXXXXX)
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String summary;
  final String? details;
  final String category;
  final String severity;
  final ReportLocation location;
  final double? verificationScore;
  final String? assignedAgency;
  final List<MediaRef> media;
  final bool anonymous;
  final List<TimelineEvent>? timeline;

  Report({
    required this.id,
    this.reportId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.summary,
    this.details,
    required this.category,
    required this.severity,
    required this.location,
    this.verificationScore,
    this.assignedAgency,
    required this.media,
    required this.anonymous,
    this.timeline,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      reportId: json['report_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      summary: json['summary'] as String,
      details: json['details'] as String?,
      category: json['category'] as String,
      severity: json['severity'] as String,
      location: ReportLocation.fromJson(json['location'] as Map<String, dynamic>),
      verificationScore: json['verification_score'] != null
          ? (json['verification_score'] as num).toDouble()
          : null,
      assignedAgency: json['assigned_agency'] as String?,
      media: (json['media'] as List<dynamic>?)
              ?.map((m) => MediaRef.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      anonymous: json['anonymous'] as bool? ?? false,
      timeline: json['timeline'] != null
          ? (json['timeline'] as List<dynamic>)
              .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'summary': summary,
      'details': details,
      'category': category,
      'severity': severity,
      'location': location.toJson(),
      'verification_score': verificationScore,
      'media': media.map((m) => m.toJson()).toList(),
      'anonymous': anonymous,
    };
  }
}

class ReportLocation {
  final double latitude;
  final double longitude;
  final String county;
  final String? district;
  final String? description;

  ReportLocation({
    required this.latitude,
    required this.longitude,
    required this.county,
    this.district,
    this.description,
  });

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      county: json['county'] as String,
      district: json['district'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'county': county,
      'district': district,
      'description': description,
    };
  }
}

class MediaRef {
  final String key;
  final String type;
  final String? checksum;
  final bool? blurFaces;
  final bool? voiceMasked;

  MediaRef({
    required this.key,
    required this.type,
    this.checksum,
    this.blurFaces,
    this.voiceMasked,
  });

  factory MediaRef.fromJson(Map<String, dynamic> json) {
    return MediaRef(
      key: json['key'] as String,
      type: json['type'] as String,
      checksum: json['checksum'] as String?,
      blurFaces: json['blur_faces'] as bool?,
      voiceMasked: json['voice_masked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'type': type,
      'checksum': checksum,
      'blur_faces': blurFaces,
      'voice_masked': voiceMasked,
    };
  }
}

class TimelineEvent {
  final String type; // 'created', 'verified', 'assigned', 'status_changed', etc.
  final String description;
  final DateTime timestamp;
  final String? actor;

  TimelineEvent({
    required this.type,
    required this.description,
    required this.timestamp,
    this.actor,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actor: json['actor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (actor != null) 'actor': actor,
    };
  }
}
