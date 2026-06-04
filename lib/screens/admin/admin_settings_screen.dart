import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../widgets/admin_guard.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminGuard(
      child: Scaffold(
        body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a1560),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('ADMIN',
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Admin Settings',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    )),
                const SizedBox(height: 24),

                _buildSection('App Configuration', [
                  _buildTile('📢', 'Push Notifications',
                      'Send broadcast to all users'),
                  _buildTile('🔑', 'API Keys', 'Manage backend API keys'),
                  _buildTile('🗄️', 'Database', 'View Supabase dashboard'),
                ]),
                const SizedBox(height: 20),

                _buildSection('Content', [
                  _buildTile(
                      '📖', 'Manage Shlokas', 'Edit or add shloka content'),
                  _buildTile(
                      '🏷️', 'Categories & Tags', 'Manage shloka themes'),
                  _buildTile(
                      '🚨', 'Reported Content', 'Review flagged content'),
                ]),
                const SizedBox(height: 20),

                _buildSection('Admin Account', [
                  _buildTile('👥', 'Admin Team', 'Manage admin credentials'),
                  _buildTile('📋', 'Audit Logs', 'View admin activity history'),
                ]),
                const SizedBox(height: 20),

                // Logout
                GestureDetector(
                  onTap: () async {
                    if (context.mounted) {
                      ref.read(adminProvider.notifier).logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Text('Log Out of Admin',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.warmGrey,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(children: [
                      e.value,
                      if (e.key < children.length - 1)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1,
                          color: AppColors.border,
                        ),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(String emoji, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBrown,
                    )),
                Text(subtitle,
                    style: GoogleFonts.lato(
                        fontSize: 12, color: AppColors.warmGrey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppColors.warmGrey),
        ],
      ),
    );
  }
}
