import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shloka_model.dart';
import '../theme/app_theme.dart';

class ShlokaCard extends StatelessWidget {
  final ShlokaModel shloka;
  final VoidCallback? onAskKrishna;
  final VoidCallback? onTap;

  const ShlokaCard({
    super.key,
    required this.shloka,
    this.onAskKrishna,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number
              Text(
                '${shloka.chapter}.${shloka.verse}',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // Sanskrit
              Text(
                shloka.sanskrit,
                style: GoogleFonts.tiroDevanagariSanskrit(
                  fontSize: 16,
                  color: AppColors.darkBrown,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),

              // Gold divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0),
                      AppColors.gold.withValues(alpha: 0.5),
                      AppColors.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Transliteration
              Text(
                shloka.transliteration,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: AppColors.warmGrey,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),

              // English
              Text(
                shloka.english,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 15,
                  color: AppColors.warmGrey,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                ),
              ),

              if (onAskKrishna != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onAskKrishna,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Ask Krishna 🪷',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
