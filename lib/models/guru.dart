class Guru {
  const Guru({
    required this.id,
    required this.name,
    required this.title,
    required this.specializations,
    required this.contact,
    required this.available,
  });

  final String id;
  final String name;
  final String title;
  final List<String> specializations;
  final String contact;
  final bool available;

  factory Guru.fromJson(Map<String, dynamic> json) {
    final raw = json['specializations'];
    return Guru(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      specializations: raw is List
          ? raw.map((e) => e.toString()).toList()
          : <String>[],
      contact: json['contact']?.toString() ?? '',
      available: json['available'] == true,
    );
  }

  /// Serialises fields sent to the API.
  /// id is excluded — the server assigns it on insert.
  /// admin_key is injected by GuruRepository, not stored on the model.
  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'specializations': specializations,
        'contact': contact,
        'available': available,
      };

  Guru copyWith({
    String? id,
    String? name,
    String? title,
    List<String>? specializations,
    String? contact,
    bool? available,
  }) =>
      Guru(
        id: id ?? this.id,
        name: name ?? this.name,
        title: title ?? this.title,
        specializations: specializations ?? this.specializations,
        contact: contact ?? this.contact,
        available: available ?? this.available,
      );
}