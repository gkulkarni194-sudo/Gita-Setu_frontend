import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';

class ChapterVideoPlayerScreen extends StatefulWidget {
  final int chapterNum;
  final String videoUrl;

  const ChapterVideoPlayerScreen({
    super.key,
    required this.chapterNum,
    required this.videoUrl,
  });

  @override
  State<ChapterVideoPlayerScreen> createState() =>
      _ChapterVideoPlayerScreenState();
}

class _ChapterVideoPlayerScreenState extends State<ChapterVideoPlayerScreen> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideo = _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Chapter ${widget.chapterNum} Recital',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder<void>(
                  future: _initializeVideo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CircularProgressIndicator(
                        color: AppColors.primary,
                      );
                    }

                    if (snapshot.hasError || !_controller.value.isInitialized) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unable to load chapter recital.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(color: Colors.white70),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: _togglePlayback,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            if (!_controller.value.isPlaying)
                              const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 72,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_controller.value.isInitialized)
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white12,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
              onPressed: _togglePlayback,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
