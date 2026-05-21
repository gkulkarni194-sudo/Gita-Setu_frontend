import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../providers/app_providers.dart';
import 'mood_response_screen.dart';

class MoodInputScreen extends ConsumerStatefulWidget {
  const MoodInputScreen({super.key});

  @override
  ConsumerState<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends ConsumerState<MoodInputScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedMood = -1;
  bool _loading = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😕', 'label': 'Confused'},
    {'emoji': '🙂', 'label': 'Okay'},
    {'emoji': '😌', 'label': 'Peaceful'},
  ];

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final response = await ref
          .read(aiRepositoryProvider)
          .analyzeMood(_controller.text.trim());
          
      if (mounted) {
        if (!response.success || response.data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to analyze mood.'),
              action: SnackBarAction(label: 'Retry', onPressed: _submit),
            ),
          );
          return;
        }

        final data = response.data;
        if (data is! Map) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('The mood response was unreadable.'),
              action: SnackBarAction(label: 'Retry', onPressed: _submit),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MoodResponseScreen(
              result: Map<String, dynamic>.from(data),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            action: SnackBarAction(label: 'Retry', onPressed: _submit),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),

                Text(
                  'How are you feeling?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Krishna is listening 🪷',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 28),

                // Mood selectors
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_moods.length, (index) {
                    final isSelected = _selectedMood == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = index),
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.saffronLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _moods[index]['emoji']!,
                              style: const TextStyle(fontSize: 26),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _moods[index]['label']!,
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Text input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Tell me what\'s on your mind...',
                      hintStyle: GoogleFonts.lato(
                        color: AppColors.warmGrey,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: AppColors.darkBrown,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Find My Shloka →',
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
      ),
    );
  }
}
