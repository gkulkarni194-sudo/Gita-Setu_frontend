import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/auth/login_screen.dart';

class AdminGuard extends ConsumerStatefulWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  ConsumerState<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends ConsumerState<AdminGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isAdmin = ref.read(adminProvider);
      if (!isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(adminProvider);
    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
