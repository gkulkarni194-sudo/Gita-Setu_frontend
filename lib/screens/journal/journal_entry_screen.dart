import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import 'journal_analysis_screen.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, this.entry});

  final JournalEntry? entry;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _saving = false;
  bool _analyzing = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      _titleController.text = entry.title ?? '';
      _contentController.text = entry.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<JournalEntry?> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before saving.')),
      );
      return null;
    }

    setState(() => _saving = true);
    try {
      final notifier = ref.read(journalEntriesProvider.notifier);
      final title = _titleController.text.trim();
      final saved = _isEditing
          ? await notifier.update(
              widget.entry!,
              title: title.isEmpty ? null : title,
              content: content,
            )
          : await notifier.create(
              title: title.isEmpty ? null : title,
              content: content,
            );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal saved locally.')),
        );
      }
      return saved;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndAnalyze() async {
    if (_saving || _analyzing) return;
    final saved = await _save();
    if (saved == null) return;

    setState(() => _analyzing = true);
    try {
      final response = await ref
          .read(journalRepositoryProvider)
          .requestAiReflection(saved.content);
      if (!mounted) return;

      if (!response.success || response.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to analyze'),
            action: SnackBarAction(label: 'Retry', onPressed: _saveAndAnalyze),
          ),
        );
        return;
      }

      final data = response.data;
      if (data is! Map) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('The journal reflection was unreadable.'),
            action: SnackBarAction(label: 'Retry', onPressed: _saveAndAnalyze),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JournalAnalysisScreen(
            result: Map<String, dynamic>.from(data),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            action: SnackBarAction(label: 'Retry', onPressed: _saveAndAnalyze),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _delete() async {
    final entry = widget.entry;
    if (entry == null) return;
    await ref.read(journalEntriesProvider.notifier).delete(entry.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy').format(DateTime.now());

    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const Spacer(),
                    if (_isEditing)
                      IconButton(
                        onPressed: _delete,
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditing ? 'Edit Entry' : 'Today\'s Entry',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _buildQuoteCard(),
                const SizedBox(height: 16),
                _buildTitleField(),
                const SizedBox(height: 12),
                Expanded(child: _buildContentField()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving || _analyzing ? null : _save,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Save',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _saving || _analyzing ? null : _saveAndAnalyze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: _analyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Reflect',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.saffronLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_florist_outlined, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"Let right deeds be thy motive, not the fruit which comes from them."',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 14,
                color: AppColors.darkBrown,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Optional title',
          hintStyle: GoogleFonts.lato(color: AppColors.warmGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: GoogleFonts.lato(fontSize: 15, color: AppColors.darkBrown),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText:
              'Write about your day...\n\nWhat did you do? How did you feel? What choices did you make?',
          hintStyle: GoogleFonts.lato(
            color: AppColors.warmGrey,
            fontStyle: FontStyle.italic,
            height: 1.7,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: GoogleFonts.lato(
          fontSize: 15,
          color: AppColors.darkBrown,
          height: 1.7,
        ),
      ),
    );
  }
}
