import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../widgets/shloka_card.dart';
import 'ai_chat_screen.dart';

class ChapterDetailScreen extends ConsumerWidget {
  final int chapterNum;

  const ChapterDetailScreen({super.key, required this.chapterNum});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = AppConstants.chapters[chapterNum - 1];
    final shlokas = ref.watch(chapterShlokasProvider(chapterNum));

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
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
                    const SizedBox(height: 12),
                    Text(
                      'Chapter $chapterNum - ${chapter['name']}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapter['sanskrit'] ?? '',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.gold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.saffronLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Text(
                        'Explore ${chapter['verses']} verses of wisdom',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 14,
                          color: AppColors.darkBrown,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: shlokas.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(color: AppColors.warmGrey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref
                                .invalidate(chapterShlokasProvider(chapterNum)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No verses found for this chapter.',
                          style: GoogleFonts.lato(color: AppColors.warmGrey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final shloka = items[index];
                        return ShlokaCard(
                          shloka: shloka,
                          onAskKrishna: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AiChatScreen(shloka: shloka),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
