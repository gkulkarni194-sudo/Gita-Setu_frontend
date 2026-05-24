// lib/screens/gita/shloka_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/shloka_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'ai_chat_screen.dart';

class ShlokaDetailScreen extends StatelessWidget {
  final ShlokaModel shloka;

  const ShlokaDetailScreen({super.key, required this.shloka});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AiChatScreen(shloka: shloka)),
        ),
        backgroundColor: AppColors.primary,
        child: const Text('🪷', style: TextStyle(fontSize: 20)),
      ),
      backgroundColor: Colors.transparent,
      body: FlowerBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chapter ${shloka.chapter}, Verse ${shloka.verse}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.saffronLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              shloka.sanskrit,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tiroDevanagariSanskrit(
                                fontSize: 22,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              shloka.transliteration,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: AppColors.darkBrown,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Translation',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        shloka.english,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          color: AppColors.darkBrown,
                          height: 1.6,
                        ),
                      ),
                      if (shloka.purport.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Purport',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          shloka.purport,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            color: AppColors.warmGrey,
                            height: 1.6,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiChatScreen(shloka: shloka),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪷', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Ask Krishna about this verse',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
}
