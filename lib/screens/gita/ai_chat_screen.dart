import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../models/shloka_model.dart';
import '../../providers/app_providers.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final ShlokaModel shloka;

  const AiChatScreen({super.key, required this.shloka});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _loading = false;
  String? _lastFailedQuestion;

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': question});
      _lastFailedQuestion = null;
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await ref.read(aiRepositoryProvider).explainShloka(
            chapter: widget.shloka.chapter,
            verse: widget.shloka.verse,
            question: question,
            history: List<Map<String, String>>.from(_history),
          );

      if (!response.success || response.data == null) {
        setState(() {
          _lastFailedQuestion = question;
          _messages.add({
            'role': 'ai',
            'content': response.error?.message ?? 'I could not reach the server. Please try again.',
          });
          _loading = false;
        });
        _scrollToBottom();
        return;
      }
      
      final data = response.data;
      final content = data is Map
          ? (data['answer'] ?? data['explanation'] ?? '').toString()
          : data.toString();

      setState(() {
        _messages.add({
          'role': 'ai',
          'content': content.isEmpty
              ? 'I could not read the server response. Please try again.'
              : content,
        });
        _history.add({'question': question, 'answer': content});
        _lastFailedQuestion = null;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _lastFailedQuestion = question;
        _messages.add({
          'role': 'ai',
          'content': 'An unexpected error occurred. Please try again.',
        });
        _loading = false;
      });
    }
  }

  Future<void> _retryLastFailed() async {
    final failed = _lastFailedQuestion;
    if (failed == null || _loading) return;
    _controller.text = failed;
    await _sendMessage();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _messages.clear();
    _history.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.darkBrown),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🪷', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'Ask Krishna',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'BG ${widget.shloka.chapter}.${widget.shloka.verse}',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Shloka preview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.saffronLight,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                  child: Text(
                    widget.shloka.english.length > 150
                        ? '${widget.shloka.english.substring(0, 150)}...'
                        : widget.shloka.english,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      color: AppColors.darkBrown,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _messages.length +
                      (_loading ? 1 : 0) +
                      (_lastFailedQuestion != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      if (_loading) {
                        return _buildLoadingBubble();
                      }
                      return _buildRetryButton();
                    }
                    if (index > _messages.length) {
                      return _buildLoadingBubble();
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(
                      msg['content']!,
                      isUser: msg['role'] == 'user',
                    );
                  },
                ),
              ),

              // Input bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Ask anything about this verse...',
                            hintStyle: GoogleFonts.lato(
                              color: AppColors.warmGrey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _loading ? null : _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.darkBrown : AppColors.saffronLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: isUser ? Colors.white : AppColors.darkBrown,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.saffronLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪷', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.warmGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton.icon(
          onPressed: _retryLastFailed,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
