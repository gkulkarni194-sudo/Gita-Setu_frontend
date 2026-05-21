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
