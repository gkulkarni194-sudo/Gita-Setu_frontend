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

    final siva = json['siva'];
    final sivaMap = siva is Map ? siva : const <String, dynamic>{};

    return ShlokaModel(
      id: json['id']?.toString() ?? '',
      chapter: parseInt(json['chapter']),
      verse: parseInt(json['verse']),
      sanskrit: json['sanskrit']?.toString() ?? json['slok']?.toString() ?? '',
      transliteration: json['transliteration']?.toString() ?? '',
      english: json['english']?.toString() ??
          json['translation']?.toString() ??
          sivaMap['et']?.toString() ??
          '',
      purport: json['purport']?.toString() ??
          json['meaning']?.toString() ??
          sivaMap['ec']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter': chapter,
      'verse': verse,
      'sanskrit': sanskrit,
      'transliteration': transliteration,
      'english': english,
      'purport': purport,
    };
  }
}
