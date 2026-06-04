import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/profile_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../home/home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'step': '01',
      'emoji': '📖',
      'title': 'Read the Gita',
      'subtitle': 'All 700 verses in your pocket',
      'description':
          'Tap the Gita tab at the bottom. Browse all 18 chapters. Tap any chapter to see all its verses with Sanskrit text, transliteration, and English translation side by side.',
      'tips': [
        'Swipe between verses with the Previous / Next buttons',
        'Tap "Ask Krishna 🪷" on any verse to start a conversation about it',
        'Listen to Sanskrit recitation with the audio player',
      ],
    },
    {
      'step': '02',
      'emoji': '🪷',
      'title': 'Ask Krishna',
      'subtitle': 'Your personal AI Gita scholar',
      'description':
          'On any shloka, tap "Ask Krishna 🪷". A chat opens where you can ask anything about that verse — who are the characters, what does this mean for my life, can you explain this simply?',
      'tips': [
        'Ask "Who is Dhritarashtra?" on verse 1.1',
        'Ask "How does this apply to my exams?"',
        'The AI reads Prabhupada\'s full commentary before answering',
        'Your conversation history is saved within the session',
      ],
    },
    {
      'step': '03',
      'emoji': '🫀',
      'title': 'Mood Companion',
      'subtitle': 'Krishna listens to how you feel',
      'description':
          'Tap the Mood tab. Select how you\'re feeling and write what\'s on your mind in your own words. The AI finds the most relevant Gita verses for your exact situation and responds with personal guidance.',
      'tips': [
        'Be honest — write exactly how you feel',
        'The more you share, the more personal the guidance',
        'Try: "I feel scared about my future and don\'t know what to do"',
        'Save responses you find meaningful',
      ],
    },
    {
      'step': '04',
      'emoji': '📓',
      'title': 'Karma Journal',
      'subtitle': 'Understand your actions through the Gita',
      'description':
          'Tap the Journal tab. Write about your day — what happened, what choices you made, how you acted. The AI analyzes your entry through the lens of the three types of karma.',
      'tips': [
        'Write about a conflict, decision, or regret from your day',
        'The AI identifies Sanchita, Prarabdha and Kriyamana karma',
        'Past entries are saved so you can track your growth',
        'Try writing about something you did that you\'re not proud of',
      ],
    },
    {
      'step': '05',
      'emoji': '🧘',
      'title': 'Talk to a Mentor',
      'subtitle': 'Connect with ISKCON guides',
      'description':
          'Browse real ISKCON monks, Vedic counselors, and Gita scholars. Filter by what you need help with and book a one-on-one session in video, voice, or chat format.',
      'tips': [
        'Filter by specialization: Anxiety, Career, Relationships',
        'View mentor profiles and session counts',
        'Book video, voice, or chat sessions',
        'See your upcoming sessions in My Sessions',
      ],
    },
    {
      'step': '06',
      'emoji': '⚙️',
      'title': 'Personalize GitaSetu',
      'subtitle': 'Make it yours',
      'description':
          'Tap Settings to customize your experience. Change the app theme between Cream, White, Grey and Dark mode. Set your name, manage notifications, and access your weekly karma report.',
      'tips': [
        'Try Dark mode for night reading',
        'Enable Daily Shloka Reminder to start your mornings with wisdom',
        'Your streak keeps track of daily engagement',
        'Weekly report shows your mood trends and karma patterns',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final box = Hive.box<dynamic>(ProfileLocalService.boxName);
    await box.put('tutorialSeen', true);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) =>
                    _buildStep(_steps[index]),
              ),

              // Skip button
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: _finish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Skip to App',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.warmGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom nav
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _steps.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Text(
                            '${_currentPage + 1} of ${_steps.length}',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: AppColors.warmGrey,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              shadowColor: AppColors.primary
                                  .withValues(alpha: 0.3),
                            ),
                            child: Text(
                              _currentPage == _steps.length - 1
                                  ? 'Begin My Journey 🪷'
                                  : 'Next →',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(Map<String, dynamic> step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),

          // Step badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'STEP ${step['step']}',
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Emoji
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                step['emoji'] as String,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            step['title'] as String,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            step['subtitle'] as String,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Gold divider
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            step['description'] as String,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: AppColors.warmGrey,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),

          // Tips card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Tips',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...(step['tips'] as List<String>).map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 7),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: AppColors.darkBrown,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}