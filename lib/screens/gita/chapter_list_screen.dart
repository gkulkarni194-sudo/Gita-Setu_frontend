import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../local/cache_local_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../constants/app_constants.dart';
import 'chapter_detail_screen.dart';

class ChapterListScreen extends StatelessWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cachedChapters = CacheLocalService(
      Hive.box<dynamic>(CacheLocalService.boxName),
    ).getChapterMetadata();
    final chapters =
        cachedChapters.isEmpty ? AppConstants.chapters : cachedChapters;

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Navigator.canPop(context))
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            color: AppColors.darkBrown),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Bhagavad Gita',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '18 Chapters • 697 Shlokas',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return _buildChapterCard(context, chapter);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, Map<dynamic, dynamic> chapter) {
    final chapterNum = chapter['num'].toString();
    final chapterName = chapter['name']?.toString() ?? '';
    final sanskrit = chapter['sanskrit']?.toString() ?? '';
    final verses = chapter['verses']?.toString() ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChapterDetailScreen(chapterNum: int.parse(chapterNum)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            // Chapter number
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.saffronLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  chapterNum,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Vertical divider
            Container(width: 1, height: 48, color: AppColors.border),
            const SizedBox(width: 14),

            // Chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapterName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sanskrit,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.gold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Verse count
            Text(
              '$verses verses',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.warmGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
