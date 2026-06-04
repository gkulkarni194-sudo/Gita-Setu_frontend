import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/profile_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'tutorial_screen.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'emoji': '🌊',
      'title': 'Drowning in Anxiety?',
      'subtitle': 'You are not alone.',
      'body':
          '1 in 3 Gen Z individuals report feeling anxious or overwhelmed every single day. The pressure of exams, careers, relationships, and an uncertain future can feel suffocating.\n\nThe Bhagavad Gita was spoken on a battlefield — to a warrior who broke down in anxiety. It was written for exactly this moment.',
      'quote': '"Do not grieve. The soul is eternal."',
      'quoteRef': '— Bhagavad Gita 2.20',
    },
    {
      'emoji': '🧭',
      'title': 'Lost Without Direction?',
      'subtitle': 'Purpose is closer than you think.',
      'body':
          'Arjuna was one of the greatest warriors alive — and yet he sat in his chariot, paralyzed, asking "what is the point of any of this?"\n\nIf the greatest warrior in history questioned his purpose, so can you. And Krishna answered him. GitaSetu brings that answer to your phone.',
      'quote': '"You have a right to perform your duties, but never to the fruits."',
      'quoteRef': '— Bhagavad Gita 2.47',
    },
    {
      'emoji': '💔',
      'title': 'Hurt by Someone You Loved?',
      'subtitle': 'Attachment is the root of suffering.',
      'body':
          'The Gita does not tell you not to love. It teaches you how to love without being destroyed by loss. Detachment is not coldness — it is freedom.\n\nWhen grief feels unbearable, GitaSetu finds the exact verse that speaks to your pain.',
      'quote': '"One who is not disturbed by happiness and distress is steady in both."',
      'quoteRef': '— Bhagavad Gita 2.15',
    },
    {
      'emoji': '🔥',
      'title': 'Why the Bhagavad Gita?',
      'subtitle': '5,000 years. Still relevant.',
      'body':
          'Every human struggle you face today — identity, duty, fear, grief, desire, purpose — was addressed in 700 verses spoken in 18 chapters on a single morning.\n\nScientists, presidents, philosophers, and athletes have drawn wisdom from this text. Now it is yours.',
      'quote': '"Whenever dharma declines, I manifest myself."',
      'quoteRef': '— Bhagavad Gita 4.7',
    },
    {
      'emoji': '🪷',
      'title': 'Why GitaSetu?',
      'subtitle': 'Ancient wisdom. Modern life.',
      'body':
          'GitaSetu is not just a Gita reader. It is a spiritual companion that listens to how you feel, searches all 700 verses for what applies to you, and responds with the wisdom of Krishna — warm, personal, and grounded in real scripture.\n\nYour journal. Your moods. Your karma. Your path.',
      'quote': '"I am the beginning, middle and end of all beings."',
      'quoteRef': '— Bhagavad Gita 10.20',
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

  Future<void> _goToTutorial() async {
    final box = Hive.box<dynamic>(ProfileLocalService.boxName);
    await box.put('inspirationSeen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const TutorialScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToTutorial();
    }
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
                itemCount: _slides.length,
                itemBuilder: (context, index) =>
                    _buildSlide(_slides[index]),
              ),

              // Skip button
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: _goToTutorial,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Skip',
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
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 24 : 8,
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

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            shadowColor:
                                AppColors.primary.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1
                                ? 'Show Me How It Works →'
                                : 'Continue →',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),

          // Emoji in a soft card
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
                slide['emoji'] as String,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            slide['title'] as String,
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
            slide['subtitle'] as String,
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

          // Body text
          Text(
            slide['body'] as String,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: AppColors.warmGrey,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 28),

          // Quote card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide['quote'] as String,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 17,
                    color: AppColors.darkBrown,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide['quoteRef'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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