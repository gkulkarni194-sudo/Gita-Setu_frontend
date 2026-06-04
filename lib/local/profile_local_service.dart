import 'package:hive_flutter/hive_flutter.dart';

import '../models/profile_model.dart';

class ProfileLocalService {
  ProfileLocalService(this._box);

  static const String boxName = 'local_profile';
  static const String profileKey = 'profile';
  static const String disclaimerAcceptedKey = 'disclaimerAccepted';
  static const String termsAcceptedKey = 'termsAccepted';

  final Box<dynamic> _box;

  ProfileModel? getProfile() {
    final raw = _box.get(profileKey);
    if (raw is Map) return ProfileModel.fromMap(raw);
    return null;
  }

  bool get hasProfile => getProfile() != null;

  bool get disclaimerAccepted {
    final profile = getProfile();
    return profile?.disclaimerAccepted ??
        (_box.get(disclaimerAcceptedKey) == true);
  }

  bool get termsAccepted {
    final profile = getProfile();
    return profile?.termsAccepted ?? (_box.get(termsAcceptedKey) == true);
  }

  Future<void> acceptDisclaimer() async {
    final now = DateTime.now();
    await _box.put(disclaimerAcceptedKey, true);
    final profile = getProfile();
    if (profile != null) {
      await saveProfile(
        profile.copyWith(
          disclaimerAccepted: true,
          disclaimerAcceptedAt: profile.disclaimerAcceptedAt ?? now,
        ),
      );
    }
  }

  Future<void> acceptTerms() async {
    final now = DateTime.now();
    await _box.put(termsAcceptedKey, true);
    final profile = getProfile();
    if (profile != null) {
      await saveProfile(
        profile.copyWith(
          termsAccepted: true,
          termsAcceptedAt: profile.termsAcceptedAt ?? now,
        ),
      );
    }
  }

  Future<void> createProfile(String name) async {
    final now = DateTime.now();
    final profile = ProfileModel(
      name: name.trim(),
      createdAt: now,
      disclaimerAccepted: true,
      termsAccepted: true,
      disclaimerAcceptedAt: now,
      termsAcceptedAt: now,
    );
    await _box.put(disclaimerAcceptedKey, true);
    await _box.put(termsAcceptedKey, true);
    await saveProfile(profile);
  }

  Future<void> saveProfile(ProfileModel profile) {
    return _box.put(profileKey, profile.toMap());
  }

  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final profile = getProfile();
    if (profile == null) {
      await createProfile(trimmed);
      return;
    }
    await saveProfile(profile.copyWith(name: trimmed));
  }

  Stream<BoxEvent> watch() => _box.watch();
}
