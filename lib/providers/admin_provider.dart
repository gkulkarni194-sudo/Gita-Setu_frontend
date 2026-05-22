import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}

final adminProvider = NotifierProvider<AdminNotifier, bool>(() {
  return AdminNotifier();
});

/// Holds the admin password entered at the login prompt for the current session.
/// Set after a successful /admin/verify call.
/// Never persisted to disk — session-only.
///
/// Set:   ref.read(adminPasswordProvider.notifier).state = enteredPassword;
/// Read:  final key = ref.read(adminPasswordProvider);
final adminPasswordProvider = StateProvider<String>((ref) => '');