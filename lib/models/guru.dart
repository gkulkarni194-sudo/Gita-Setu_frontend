class Guru {
  const Guru({
    required this.id,
    required this.name,
    required this.title,
    required this.specializations,
    required this.rating,

    required this.emoji,
    required this.available,

  });

  final String id;
  final String name;
  final String title;
  final List<String> specializations;
  final double rating;

  final String emoji;
  final bool available;


  factory Guru.fromJson(Map<String, dynamic> json) {
    final rawSpecializations = json['specializations'];
    return Guru(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      specializations: rawSpecializations is List
          ? rawSpecializations.map((item) => item.toString()).toList()
          : <String>[],
      rating: _parseDouble(json['rating']),

      emoji: json['emoji']?.toString() ?? '',
      available: json['available'] == true,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'specializations': specializations,
      'rating': rating,

      'emoji': emoji,
      'available': available,

    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
