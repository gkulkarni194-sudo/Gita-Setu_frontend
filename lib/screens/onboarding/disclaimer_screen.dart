import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/profile_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'terms_screen.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    final profileService = ProfileLocalService(
      Hive.box<dynamic>(ProfileLocalService.boxName),
    );
    await profileService.acceptDisclaimer();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFFB300), width: 2),
                        ),
                        child: const Center(
                            child: Text('⚠️', style: TextStyle(fontSize: 36))),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Medical & Mental Health\nDisclaimer',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please read carefully before continuing',
                        style: GoogleFonts.lato(
                            fontSize: 13, color: AppColors.warmGrey),
                      ),
                      const SizedBox(height: 28),

                      _buildCard('🚫', 'Not Medical Advice',
                          'GitaSetu and its AI "Mood Companion" are NOT medical, diagnostic, or therapeutic services. The information provided is for spiritual and philosophical guidance only.'),
                      _buildCard('👨‍⚕️', 'Not a Substitute',
                          'This app is NOT a substitute for professional advice from a doctor, psychiatrist, therapist, or other healthcare professional. Never delay seeking professional help because of something you read on GitaSetu.'),
                      _buildCard('🆘', 'Emergency Situations',
                          'IF YOU ARE EXPERIENCING A MENTAL HEALTH CRISIS, CONTEMPLATING SELF-HARM, OR IN A LIFE-THREATENING EMERGENCY — DO NOT USE THIS APP. Contact emergency services (112 in India) or a crisis hotline immediately.'),
                      _buildCard('⚖️', 'Limitation of Liability',
                          'GitaSetu is not responsible for any actions taken based on AI-generated advice. Use of the Karma Journal and Mood Companion is entirely at your own risk.'),

                      // Crisis helplines
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFFFB300), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🆘 Crisis Helplines (India)',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF856404),
                                )),
                            const SizedBox(height: 10),
                            _buildHelpline('iCall', '9152987821'),
                            _buildHelpline(
                                'Vandrevala Foundation', '1860-2662-345'),
                            _buildHelpline('AASRA', '9820466627'),
                            _buildHelpline('Emergency Services', '112'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _continue(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'I Understand — Begin My Journey 🪷',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String emoji, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
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
                const SizedBox(height: 5),
                Text(content,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: AppColors.warmGrey,
                      height: 1.6,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpline(String name, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('• ',
              style: GoogleFonts.lato(
                  color: const Color(0xFF856404), fontWeight: FontWeight.bold)),
          Text('$name: ',
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF856404),
              )),
          Text(number,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: const Color(0xFF856404),
              )),
        ],
      ),
    );
  }
}
