import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../widgets/admin_guard.dart';
import 'admin_mentor_screen.dart';
import 'admin_settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardTab(),
    const AdminMentorScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1a1560),
          border: Border(
            top: BorderSide(color: AppColors.gold, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1a1560),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(
                icon: Text('📊', style: TextStyle(fontSize: 22)),
                label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Text('🧘', style: TextStyle(fontSize: 22)),
                label: 'Mentors'),
            BottomNavigationBarItem(
                icon: Text('⚙️', style: TextStyle(fontSize: 22)),
                label: 'Settings'),
          ],
        ),
      ),
    ));
  }
}

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1560),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text('ADMIN',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text('Admin Dashboard',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    )),
                Text('Manage GitaSetu',
                    style: GoogleFonts.lato(
                        fontSize: 14, color: AppColors.warmGrey)),
                const SizedBox(height: 28),

                // Stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard('👥', '1,247', 'Total Users'),
                    _buildStatCard('🧘', '8', 'Active Mentors'),
                    _buildStatCard('📖', '697', 'Shlokas'),
                    _buildStatCard('💬', '3,891', 'AI Queries'),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Quick Actions',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    )),
                const SizedBox(height: 16),

                _buildActionCard(
                    context,
                    '🧘',
                    'Manage Mentors',
                    'Add, edit or remove mentor profiles and schedules',
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminMentorScreen()))),
                _buildActionCard(context, '📢', 'Send Notification',
                    'Push notifications to all users', () {}),
                _buildActionCard(context, '📊', 'View Analytics',
                    'User engagement and feature usage stats', () {}),
                _buildActionCard(context, '🚨', 'Reported Content',
                    'Review flagged AI responses', () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              )),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 11, color: AppColors.warmGrey)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String emoji, String title,
      String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.saffronLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
