import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../local/profile_local_service.dart';
import '../../local/progress_local_service.dart';
import '../../models/profile_model.dart';
import '../../models/user_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box<dynamic>(ProfileLocalService.boxName);
    final progressBox = Hive.box<dynamic>(ProgressLocalService.boxName);

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              profileBox.listenable(),
              progressBox.listenable(),
            ]),
            builder: (context, _) {
              final profile = ProfileLocalService(profileBox).getProfile();
              final progress = ProgressLocalService(progressBox).getProgress();
              final weeklyReport =
                  ProgressLocalService(progressBox).currentWeeklyReport();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Navigator.canPop(context))
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildHeader(profile, progress),
                    const SizedBox(height: 28),
                    _buildProgressBar(progress),
                    const SizedBox(height: 28),
                    _buildStatsGrid(progress),
                    const SizedBox(height: 20),
                    _buildWeeklyReport(weeklyReport),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileModel? profile, UserProgress progress) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            profile?.name ?? 'Seeker',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        Center(
          child: Text(
            _levelName(progress.xp),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              color: AppColors.gold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(UserProgress progress) {
    final nextLevelXp = _nextLevelXp(progress.xp);
    final previousLevelXp = _previousLevelXp(progress.xp);
    final levelProgress = nextLevelXp == previousLevelXp
        ? 1.0
        : (progress.xp - previousLevelXp) / (nextLevelXp - previousLevelXp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.xp} XP',
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              progress.xp >= 1000
                  ? 'Highest level reached'
                  : '${nextLevelXp - progress.xp} XP to ${_levelName(nextLevelXp)}',
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
          child: LinearProgressIndicator(
            value: levelProgress.clamp(0, 1).toDouble(),
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserProgress progress) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildStatCard(Icons.local_fire_department, '${progress.currentStreak}',
            'Day Streak'),
        _buildStatCard(Icons.workspace_premium,
            '${progress.completedChapters.length}', 'Completed Chapters'),
        _buildStatCard(Icons.menu_book,
            progress.lastOpenedChapter?.toString() ?? '-', 'Last Chapter'),
        _buildStatCard(Icons.auto_awesome, '${progress.xp}', 'Progress Points'),
      ],
    );
  }

  Widget _buildWeeklyReport(WeeklyReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Stats',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 14),
          _buildReportRow('XP earned', '${report.xpEarned}'),
          _buildReportRow('Chapters completed', '${report.chaptersCompleted}'),
          _buildReportRow('Active days', '${report.activeDays}'),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 14, color: AppColors.warmGrey),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: AppColors.darkBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
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
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
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

  String _levelName(int xp) {
    if (xp >= 1000) return 'Jnana Yogi';
    if (xp >= 500) return 'Karma Yogi';
    if (xp >= 150) return 'Sadhaka';
    return 'Seeker';
  }

  int _nextLevelXp(int xp) {
    if (xp < 150) return 150;
    if (xp < 500) return 500;
    if (xp < 1000) return 1000;
    return 1000;
  }

  int _previousLevelXp(int xp) {
    if (xp >= 1000) return 1000;
    if (xp >= 500) return 500;
    if (xp >= 150) return 150;
    return 0;
  }
}
