import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/terms_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4');
    try {
      await _controller.initialize();
      _controller.setLooping(false);
      _controller.setVolume(1.0);
      setState(() => _videoInitialized = true);
      _controller.play();
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _navigate();
        }
      });
    } catch (e) {
      // If video fails just navigate
      await Future.delayed(const Duration(seconds: 2));
      _navigate();
    }
  }

  Future<void> _navigate() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        hasSeenOnboarding ? MainScreen() : const TermsScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigate, // Tap to skip
        child: SizedBox.expand(
          child: _videoInitialized
              ? FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          )
              : const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          ),
        ),
      ),
    );
  }
}