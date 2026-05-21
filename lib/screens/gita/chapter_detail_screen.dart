import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../../constants/app_constants.dart';
import '../../local/cache_local_service.dart';
import '../../local/progress_local_service.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/flower_background.dart';
import '../../widgets/shloka_card.dart';
import 'ai_chat_screen.dart';

class ChapterDetailScreen extends ConsumerStatefulWidget {
  final int chapterNum;

  const ChapterDetailScreen({super.key, required this.chapterNum});

  @override
  ConsumerState<ChapterDetailScreen> createState() =>
      _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends ConsumerState<ChapterDetailScreen> {
  @override
  void initState() {
    super.initState();
    ProgressLocalService(Hive.box<dynamic>(ProgressLocalService.boxName))
        .recordChapterOpened(widget.chapterNum);
  }

  @override
  Widget build(BuildContext context) {
    final chapterNum = widget.chapterNum;
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
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No verses found for this chapter.',
                                style: GoogleFonts.lato(
                                  color: AppColors.warmGrey,
                                ),
                              ),
                            ),
                          ),
                          ChapterSummaryAudioPlayer(chapterNum: chapterNum),
                          const SizedBox(height: 24),
                          ChapterCompletionCard(chapterNum: chapterNum),
                          const SizedBox(height: 24),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length + 2,
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ChapterSummaryAudioPlayer(
                              chapterNum: chapterNum,
                            ),
                          );
                        }
                        if (index == items.length + 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ChapterCompletionCard(
                              chapterNum: chapterNum,
                            ),
                          );
                        }

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

class ChapterSummaryAudioPlayer extends StatefulWidget {
  final int chapterNum;

  const ChapterSummaryAudioPlayer({super.key, required this.chapterNum});

  @override
  State<ChapterSummaryAudioPlayer> createState() =>
      _ChapterSummaryAudioPlayerState();
}

class _ChapterSummaryAudioPlayerState extends State<ChapterSummaryAudioPlayer> {
  late final AudioPlayer _player;
  late final String _audioUrl;
  StreamSubscription<Duration>? _positionSubscription;
  Duration _lastSavedAudioPosition = Duration.zero;
  bool _isLoading = true;
  bool _isAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _audioUrl = _chapterAudioUrl(widget.chapterNum);
    _loadAudio();
  }

  @override
  void dispose() {
    _saveCurrentAudioPosition();
    _positionSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _chapterAudioUrl(int chapterNum) {
    final baseUrl = AppConstants.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final mappings = CacheLocalService(
      Hive.box<dynamic>(CacheLocalService.boxName),
    ).getAudioMappings();
    final fileName = mappings['$chapterNum'] ??
        '${chapterNum.toString().padLeft(2, '0')}-Track${chapterNum.toString().padLeft(2, '0')}.mp3';
    return '$baseUrl/static/audio/$fileName';
  }

  Future<void> _loadAudio() async {
    if (widget.chapterNum < 1 || widget.chapterNum > 15) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAvailable = false;
          _errorMessage = null;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _player.setUrl(_audioUrl).timeout(AppConstants.requestTimeout);
      final savedPosition =
          ProgressLocalService(Hive.box<dynamic>(ProgressLocalService.boxName))
              .audioProgressFor(widget.chapterNum);
      if (savedPosition > Duration.zero) {
        await _player.seek(savedPosition);
      }
      _trackAudioProgress();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isAvailable = true;
        _errorMessage = null;
      });
    } on TimeoutException {
      _showAudioError('Audio is taking too long to load.');
    } on PlayerException catch (error) {
      if (_looksLikeMissingFile(error)) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isAvailable = false;
          _errorMessage = null;
        });
        return;
      }
      _showAudioError('Audio playback is unavailable right now.');
    } catch (_) {
      _showAudioError('Audio playback is unavailable right now.');
    }
  }

  bool _looksLikeMissingFile(PlayerException error) {
    final details = '${error.code} ${error.message}'.toLowerCase();
    return details.contains('404') || details.contains('not found');
  }

  void _showAudioError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isAvailable = true;
      _errorMessage = message;
    });
  }

  Future<void> _togglePlayback(PlayerState playerState) async {
    if (playerState.playing) {
      await _player.pause();
      return;
    }

    if (playerState.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  void _trackAudioProgress() {
    _positionSubscription?.cancel();
    _positionSubscription = _player.positionStream.listen((position) {
      if ((position - _lastSavedAudioPosition).abs() <
          const Duration(seconds: 5)) {
        return;
      }
      _lastSavedAudioPosition = position;
      ProgressLocalService(Hive.box<dynamic>(ProgressLocalService.boxName))
          .saveAudioProgress(widget.chapterNum, position);
    });
  }

  void _saveCurrentAudioPosition() {
    final position = _player.position;
    if (position > Duration.zero) {
      ProgressLocalService(Hive.box<dynamic>(ProgressLocalService.boxName))
          .saveAudioProgress(widget.chapterNum, position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && !_isAvailable && _errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapter Summary Audio',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Row(
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading audio...',
                  style: GoogleFonts.lato(color: AppColors.warmGrey),
                ),
              ],
            )
          else if (_errorMessage != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.lato(color: AppColors.warmGrey),
                  ),
                ),
                TextButton(
                  onPressed: _loadAudio,
                  child: const Text('Retry'),
                ),
              ],
            )
          else
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final isBusy = processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering;
                final isPlaying = playerState?.playing ?? false;

                return Row(
                  children: [
                    IconButton.filled(
                      onPressed: isBusy || playerState == null
                          ? null
                          : () => _togglePlayback(playerState),
                      icon: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isPlaying ? 'Playing summary' : 'Listen to summary',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: AppColors.darkBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class ChapterCompletionCard extends StatefulWidget {
  final int chapterNum;

  const ChapterCompletionCard({super.key, required this.chapterNum});

  @override
  State<ChapterCompletionCard> createState() => _ChapterCompletionCardState();
}

class _ChapterCompletionCardState extends State<ChapterCompletionCard> {
  late final ProgressLocalService _progressService;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _progressService = ProgressLocalService(
      Hive.box<dynamic>(ProgressLocalService.boxName),
    );
    _completed = _progressService.isChapterCompleted(widget.chapterNum);
  }

  Future<void> _toggleCompleted() async {
    final next = !_completed;
    await _progressService.setChapterCompleted(widget.chapterNum, next);
    if (!mounted) return;
    setState(() => _completed = next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _completed ? AppColors.saffronLight : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _completed ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _completed ? AppColors.primary : AppColors.warmGrey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _completed
                  ? 'Chapter marked complete'
                  : 'Mark this chapter complete',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _toggleCompleted,
            child: Text(_completed ? 'Undo' : 'Complete'),
          ),
        ],
      ),
    );
  }
}
