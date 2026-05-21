import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local/cache_local_service.dart';
import 'local/journal_local_service.dart';
import 'local/profile_local_service.dart';
import 'local/progress_local_service.dart';
import 'models/journal_entry.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  await Hive.openBox<JournalEntry>(JournalLocalService.boxName);
  await Hive.openBox<dynamic>(ProfileLocalService.boxName);
  await Hive.openBox<dynamic>(ProgressLocalService.boxName);
  final cacheBox = await Hive.openBox<dynamic>(CacheLocalService.boxName);
  await CacheLocalService(cacheBox).persistStaticData();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: GitaSetuApp()));
}

class GitaSetuApp extends StatelessWidget {
  const GitaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitaSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // The app must open: Splash Screen -> Home Screen (MainScreen)
      home: const SplashScreen(),
    );
  }
}
