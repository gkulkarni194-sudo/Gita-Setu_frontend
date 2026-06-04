class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.createdAt,
    required this.disclaimerAccepted,
    required this.termsAccepted,
    this.disclaimerAcceptedAt,
    this.termsAcceptedAt,
  });

  final String name;
  final DateTime createdAt;
  final bool disclaimerAccepted;
  final bool termsAccepted;
  final DateTime? disclaimerAcceptedAt;
  final DateTime? termsAcceptedAt;

  factory ProfileModel.create(String name) {
    final now = DateTime.now();
    return ProfileModel(
      name: name.trim(),
      createdAt: now,
      disclaimerAccepted: true,
      termsAccepted: true,
      disclaimerAcceptedAt: now,
      termsAcceptedAt: now,
    );
  }

  factory ProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Seeker',
      createdAt: _dateFromMap(map['createdAt']) ?? DateTime.now(),
      disclaimerAccepted: map['disclaimerAccepted'] == true,
      termsAccepted: map['termsAccepted'] == true,
      disclaimerAcceptedAt: _dateFromMap(map['disclaimerAcceptedAt']),
      termsAcceptedAt: _dateFromMap(map['termsAcceptedAt']),
    );
  }

  ProfileModel copyWith({
    String? name,
    DateTime? createdAt,
    bool? disclaimerAccepted,
    bool? termsAccepted,
    DateTime? disclaimerAcceptedAt,
    DateTime? termsAcceptedAt,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      disclaimerAcceptedAt: disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'disclaimerAccepted': disclaimerAccepted,
      'termsAccepted': termsAccepted,
      'disclaimerAcceptedAt': disclaimerAcceptedAt?.toIso8601String(),
      'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
    };
  }

  static DateTime? _dateFromMap(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
