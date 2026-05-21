import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/guru.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'mentor_profile_screen.dart';

class MentorListScreen extends ConsumerStatefulWidget {
  const MentorListScreen({super.key});

  @override
  ConsumerState<MentorListScreen> createState() => _MentorListScreenState();
}

class _MentorListScreenState extends ConsumerState<MentorListScreen> {
  int _selectedFilter = 0;

  final List<String> _filters = const [
    'All',
    'Anxiety',
    'Career',
    'Relationships',
    'Grief',
    'Purpose',
  ];


  @override
  Widget build(BuildContext context) {
    final mentorsAsync = ref.watch(gurusProvider);

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
                    Text(
                      'Talk to a Mentor',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect with ISKCON guides & Vedic counselors',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: AppColors.warmGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFilters(),
                  ],
                ),
              ),
              Expanded(
                child: mentorsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, __) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load mentors',
                            style: GoogleFonts.lato(color: AppColors.warmGrey)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(gurusProvider),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (mentors) {
                    if (mentors.isEmpty) {
                      return Center(
                        child: Text('No mentors currently available.',
                            style: GoogleFonts.lato(
                                color: AppColors.warmGrey)),
                      );
                    }
                    return _buildMentorList(_filtered(mentors));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Guru> _filtered(List<Guru> mentors) {
    final selected = _filters[_selectedFilter];
    if (selected == 'All') return mentors;
    return mentors
        .where((mentor) => mentor.specializations.contains(selected))
        .toList();
  }

  Widget _buildMentorList(List<Guru> mentors) {
    if (mentors.isEmpty) {
      return Center(
        child: Text(
          'No mentors found.',
          style: GoogleFonts.lato(color: AppColors.warmGrey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: mentors.length,
      itemBuilder: (context, index) => _buildMentorCard(mentors[index]),
    );
  }

  Widget _buildMentorCard(Guru mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.saffronLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                mentor.emoji.isEmpty
                    ? (mentor.name.isEmpty ? '?' : mentor.name.substring(0, 1))
                    : mentor.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                Text(
                  mentor.title,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: AppColors.gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: mentor.specializations
                      .take(2)
                      .map(
                        (specialization) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            specialization,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: AppColors.warmGrey,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.gold),
                  Text(
                    mentor.rating.toStringAsFixed(1),
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: AppColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MentorProfileScreen(guru: mentor),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
