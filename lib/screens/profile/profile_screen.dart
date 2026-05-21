import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.saffronLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Center(
                    child: Text('🧘', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Kritika',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                Text(
                  'Karma Yogi',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    color: AppColors.gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // XP Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '250 XP',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '300 XP to Jnana Yogi',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: AppColors.warmGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.83,
                        backgroundColor: AppColors.border,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard('📖', '47', 'Shlokas Read'),
                    _buildStatCard('📓', '12', 'Journal Entries'),
                    _buildStatCard('🫀', '18', 'Mood Check-ins'),
                    _buildStatCard('🔥', '7', 'Day Streak'),
                  ],
                ),
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
        border: Border.all(color: AppColors.border, width: 1),
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
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: AppColors.warmGrey,
            ),
          ),
        ],
      ),
    );
  }
}
