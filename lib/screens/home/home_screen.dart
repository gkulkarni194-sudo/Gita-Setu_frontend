import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/profile_local_service.dart';
import '../../local/progress_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../models/shloka_model.dart';
import '../../providers/app_providers.dart';
import '../gita/chapter_list_screen.dart';
import '../mentor/mentor_list_screen.dart';
import '../mood/mood_input_screen.dart';
import '../journal/journal_home_screen.dart';
import '../settings/settings_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ChapterListScreen(),
    const MoodInputScreen(),
    const JournalHomeScreen(),
    const SettingsScreen(),  // Replace MentorListScreen or add as 6th
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.warmGrey,
          selectedLabelStyle: GoogleFonts.lato(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.lato(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 22)), label: 'Home'),
            BottomNavigationBarItem(icon: Text('📖', style: TextStyle(fontSize: 22)), label: 'Gita'),
            BottomNavigationBarItem(icon: Text('🫀', style: TextStyle(fontSize: 22)), label: 'Mood'),
            BottomNavigationBarItem(icon: Text('📓', style: TextStyle(fontSize: 22)), label: 'Journal'),
            BottomNavigationBarItem(icon: Text('⚙️', style: TextStyle(fontSize: 22)), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  ShlokaModel? _dailyShloka;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyShloka();
  }

  Future<void> _loadDailyShloka() async {
    try {
      final shloka = await ref.read(gitaRepositoryProvider).getDailyShloka();
      if (mounted) {
        setState(() {
          _dailyShloka = shloka;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box<dynamic>(ProfileLocalService.boxName);
    final progressBox = Hive.box<dynamic>(ProgressLocalService.boxName);

    return FlowerBackground(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            profileBox.listenable(),
            progressBox.listenable(),
          ]),
          builder: (context, _) {
            final profile = ProfileLocalService(profileBox).getProfile();
            final progress = ProgressLocalService(progressBox).getProgress();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Greeting
              Text(
                'Namaste, ${profile?.name ?? 'Seeker'}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 4),

              // Streak
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.currentStreak} Day Streak',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Daily Shloka Card
              _buildDailyShlokaCard(),
              const SizedBox(height: 20),

              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      '🫀',
                      'How are you feeling?',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MoodInputScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      '📓',
                      'Journal',
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JournalHomeScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gita Reader Button
              _buildActionButton(
                '📖',
                'Gita Reader',
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChapterListScreen(),
                  ),
                ),
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                '🧘',
                'Contact Guru',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentorListScreen(),
                  ),
                ),
                fullWidth: true,
              ),
            ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDailyShlokaCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.saffronLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'Shloka of the Day',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_dailyShloka != null) ...[
            Text(
              _dailyShloka!.sanskrit,
              style: GoogleFonts.tiroDevanagariSanskrit(
                fontSize: 18,
                color: AppColors.darkBrown,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppColors.gold.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              _dailyShloka!.english,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 15,
                color: AppColors.warmGrey,
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Read More →',
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String emoji,
      String label,
      VoidCallback onTap, {
        bool fullWidth = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
        child: fullWidth
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
