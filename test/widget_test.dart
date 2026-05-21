import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gitasetu_flutter/main.dart';
import 'package:gitasetu_flutter/local/journal_local_service.dart';
import 'package:gitasetu_flutter/local/profile_local_service.dart';
import 'package:gitasetu_flutter/local/progress_local_service.dart';
import 'package:gitasetu_flutter/models/journal_entry.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final tempDir = await Directory.systemTemp.createTemp('gitasetu_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }
    await Hive.openBox<JournalEntry>(JournalLocalService.boxName);
    await Hive.openBox<dynamic>(ProfileLocalService.boxName);
    await Hive.openBox<dynamic>(ProgressLocalService.boxName);

    await tester.pumpWidget(const GitaSetuApp());

    await Hive.close();
    await tempDir.delete(recursive: true);
  });
}
