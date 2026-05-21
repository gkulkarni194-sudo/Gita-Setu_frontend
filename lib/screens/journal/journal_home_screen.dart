import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'journal_entry_screen.dart';

class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.darkBrown,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Karma Journal',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reflect. Understand. Grow.',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    color: AppColors.gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                _WriteEntryCard(onTap: _openNewEntry),
                const SizedBox(height: 20),
                _buildSearchField(),
                const SizedBox(height: 20),
                Text(
                  'Past Entries',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: entries.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) =>
                              _buildEntryTile(entries[index]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(journalEntriesProvider.notifier).refresh(query: value);
        },
        decoration: InputDecoration(
          hintText: 'Search local entries',
          hintStyle: GoogleFonts.lato(color: AppColors.warmGrey),
          prefixIcon: const Icon(Icons.search, color: AppColors.warmGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEntryTile(JournalEntry entry) {
    final title = (entry.title?.trim().isNotEmpty ?? false)
        ? entry.title!.trim()
        : _preview(entry.content, 36);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) => _confirmDelete(entry),
      child: GestureDetector(
        onTap: () => _openEntry(entry),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit, size: 16, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('d MMM yyyy, h:mm a').format(entry.updatedAt),
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _preview(entry.content, 120),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppColors.warmGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(
            _searchController.text.trim().isEmpty
                ? 'No entries yet'
                : 'No matches found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: AppColors.warmGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your journal stays only on this device.',
            style: GoogleFonts.lato(fontSize: 14, color: AppColors.warmGrey),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
            'This removes the local journal entry from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(journalEntriesProvider.notifier).delete(entry.id);
      return true;
    }
    return false;
  }

  void _openNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
    );
  }

  void _openEntry(JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JournalEntryScreen(entry: entry)),
    );
  }

  String _preview(String value, int maxLength) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= maxLength) return compact;
    return '${compact.substring(0, maxLength)}...';
  }
}

class _WriteEntryCard extends StatelessWidget {
  const _WriteEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.edit_note, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              'Write Today\'s Entry',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Stored privately on this device.',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
