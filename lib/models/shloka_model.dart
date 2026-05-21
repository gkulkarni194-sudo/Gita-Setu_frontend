class ShlokaModel {
  final String id;
  final int chapter;
  final int verse;
  final String sanskrit;
  final String transliteration;
  final String english;
  final String purport;

  ShlokaModel({
    required this.id,
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.transliteration,
    required this.english,
    required this.purport,
  });

  factory ShlokaModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ShlokaModel(
      id: json['id']?.toString() ?? '',
      chapter: parseInt(json['chapter']),
      verse: parseInt(json['verse']),
      sanskrit: json['sanskrit']?.toString() ?? '',
      transliteration: json['transliteration']?.toString() ?? '',
      english: json['english']?.toString() ?? '',
      purport: json['purport']?.toString() ?? '',
    );
  }
}
