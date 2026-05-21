import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/guru.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';

class MentorProfileScreen extends StatelessWidget {
  final Guru guru;

  const MentorProfileScreen({super.key, required this.guru});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guru.name, style: GoogleFonts.playfairDisplay(color: AppColors.darkBrown)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkBrown),
      ),
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.saffronLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      guru.emoji.isEmpty ? (guru.name.isEmpty ? '?' : guru.name.substring(0, 1)) : guru.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(guru.name, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
                Text(guru.title, style: GoogleFonts.lato(fontSize: 16, color: AppColors.gold, fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                _buildInfoBadge('⭐', 'Rating', '${guru.rating}'),
                const SizedBox(height: 8),
                _buildInfoBadge('🎯', 'Specializations', guru.specializations.join(', ')),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String emoji, String title, String value) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
       ),
       child: Row(
          children: [
             Text(emoji, style: const TextStyle(fontSize: 20)),
             const SizedBox(width: 12),
             Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(title, style: GoogleFonts.lato(fontSize: 12, color: AppColors.warmGrey, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(value, style: GoogleFonts.playfairDisplay(fontSize: 15, color: AppColors.darkBrown, fontWeight: FontWeight.bold)),
                   ],
                ),
             )
          ],
       )
     );
  }
}
