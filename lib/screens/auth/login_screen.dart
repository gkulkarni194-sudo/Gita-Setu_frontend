import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../providers/app_providers.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the admin password')),
      );
      return;
    }

    setState(() => _loading = true);

    final api = ref.read(apiServiceProvider);
    final isValid = await api.verifyAdmin(password);

    if (!mounted) return;

    if (!isValid) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password. Access denied.')),
      );
      return;
    }

    ref.read(adminProvider.notifier).login();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminHomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Logo
                const Text('🪷', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                Text('Admin Access',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
                Text('Enter the passkey to proceed.',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      color: AppColors.warmGrey,
                      fontStyle: FontStyle.italic,
                    )),
                const SizedBox(height: 36),

                _buildField('Admin Password', _passwordController, Icons.lock_outline,
                    '••••••••', isPassword: true),
                const SizedBox(height: 28),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Enter Dashboard',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                
                TextButton(
                  onPressed: () {
                     Navigator.pop(context);
                  },
                  child: Text('Cancel', style: GoogleFonts.lato(fontSize: 15, color: AppColors.warmGrey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      IconData icon, String hint,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrown,
            )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.lato(
                  color: AppColors.warmGrey.withValues(alpha: 0.6),
                  fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.warmGrey, size: 20),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.warmGrey,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.lato(fontSize: 15, color: AppColors.darkBrown),
          ),
        ),
      ],
    );
  }
}
