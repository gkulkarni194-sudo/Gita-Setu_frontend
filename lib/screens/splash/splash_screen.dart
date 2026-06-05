import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../local/profile_local_service.dart';
import '../onboarding/disclaimer_screen.dart';
import '../onboarding/terms_screen.dart';
import '../onboarding/profile_creation_screen.dart';
import '../onboarding/inspiration_screen.dart';
import '../onboarding/tutorial_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _videoInitialized = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initVideo();
  }

  Future<void> _initVideo() async {
  try {
    print("Trying to load video...");

    _controller = VideoPlayerController.asset(
      'assets/videos/intro.mp4',
    );

    await _controller.initialize();

    print("Video initialized successfully!");
    print("Size: ${_controller.value.size}");
    print("Duration: ${_controller.value.duration}");

    _controller.setLooping(false);
    _controller.setVolume(1.0);

    setState(() {
      _videoInitialized = true;
    });

    _controller.play();

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_hasNavigated) {
        _navigate();
      }
    });
  } catch (e, stackTrace) {
    print("VIDEO ERROR:");
    print(e);
    print(stackTrace);
  }
}

  Future<void> _navigate() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final profileService = ProfileLocalService(
      Hive.box<dynamic>(ProfileLocalService.boxName),
    );

    // Check how far through onboarding the user is
    // Order: Disclaimer → Terms → Profile Creation → Inspiration → Tutorial → Home
    final bool disclaimerDone = profileService.disclaimerAccepted;
    final bool termsDone = profileService.termsAccepted;
    final bool profileDone = profileService.hasProfile;

    // For inspiration and tutorial we check a simple hive key
    final box = Hive.box<dynamic>(ProfileLocalService.boxName);
    final bool inspirationDone = box.get('inspirationSeen') == true;
    final bool tutorialDone = box.get('tutorialSeen') == true;

    Widget nextScreen;

    if (!disclaimerDone) {
      // Never seen the app before — start with disclaimer
      nextScreen = const DisclaimerScreen();
    } else if (!termsDone) {
      // Saw disclaimer but didn't finish terms
      nextScreen = const TermsScreen();
    } else if (!profileDone) {
      // Accepted terms but didn't create profile
      nextScreen = const ProfileCreationScreen();
    } else if (!inspirationDone) {
      // Created profile but hasn't seen inspiration slides
      nextScreen = const InspirationScreen();
    } else if (!tutorialDone) {
      // Saw inspiration but hasn't finished tutorial
      nextScreen = const TutorialScreen();
    } else {
      // Fully onboarded — go straight to app
      nextScreen = const MainScreen();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
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
        onTap: _navigate,
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
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                  ),
                ),
        ),
      ),
    );
  }
}