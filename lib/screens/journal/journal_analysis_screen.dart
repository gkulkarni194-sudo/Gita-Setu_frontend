import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/shloka_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';

class JournalAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const JournalAnalysisScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final aiResponse = (result['answer'] ?? '').toString();
    final suggested = result['suggestedShlokas'];
    final shlokas = (suggested is List ? suggested : const <dynamic>[])
        .whereType<Map>()
        .map((s) {
          try {
            return ShlokaModel.fromJson(Map<String, dynamic>.from(s));
          } catch (_) {
            return null;
          }
        })
        .whereType<ShlokaModel>()
        .toList();

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Karmic Reflection',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.local_florist_outlined,
                        color: AppColors.gold),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildKarmaPill('Sanchita', true),
                    const SizedBox(width: 8),
                    _buildKarmaPill('Prarabdha', true),
                    const SizedBox(width: 8),
                    _buildKarmaPill('Kriyamana', false),
                  ],
                ),
                const SizedBox(height: 20),
                _AnalysisCard(text: aiResponse),
                const SizedBox(height: 28),
                if (shlokas.isNotEmpty) ...[
                  Text(
                    'Shlokas for You',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...shlokas.map(_buildMiniShlokaCard),
                ],
                const SizedBox(height: 20),
                Text(
                  'AI reflection is temporary. Your journal entry remains local only.',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.warmGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKarmaPill(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          color: active ? Colors.white : AppColors.warmGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMiniShlokaCard(ShlokaModel shloka) {
    final preview = shloka.english.length > 120
        ? '${shloka.english.substring(0, 120)}...'
        : shloka.english;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BG ${shloka.chapter}.${shloka.verse}',
            style: GoogleFonts.lato(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            preview,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 14,
              color: AppColors.warmGrey,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 100,
            color: AppColors.gold,
            margin: const EdgeInsets.only(right: 16),
          ),
          Expanded(
            child: Text(
              text.isEmpty
                  ? 'No reflection was returned. Please try again.'
                  : text,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                color: AppColors.darkBrown,
                fontStyle: FontStyle.italic,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
