import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_progress.dart';

class ProgressLocalService {
  ProgressLocalService(this._box);

  static const String boxName = 'local_progress';
  static const String progressKey = 'progress';

  static const int chapterOpenedXp = 0;
  static const int chapterCompletedXp = 25;

  final Box<dynamic> _box;

  UserProgress getProgress() {
    final raw = _box.get(progressKey);
    if (raw is Map) return UserProgress.fromMap(raw);
    final progress = UserProgress.initial();
    _box.put(progressKey, progress.toMap());
    return progress;
  }

  Future<void> saveProgress(UserProgress progress) {
    return _box.put(progressKey, progress.toMap());
  }

  Future<void> recordChapterOpened(int chapterNum) {
    final progress = _recordActivity(
      getProgress().copyWith(lastOpenedChapter: chapterNum),
      xpEarned: chapterOpenedXp,
    );
    return saveProgress(progress);
  }

  Future<void> setChapterCompleted(int chapterNum, bool completed) {
    final progress = getProgress();
    final chapters = progress.completedChapters.toSet();
    final wasCompleted = chapters.contains(chapterNum);

    if (completed) {
      chapters.add(chapterNum);
    } else {
      chapters.remove(chapterNum);
    }

    var next = progress.copyWith(
      completedChapters: chapters.toList()..sort(),
    );

    next = _recordActivity(
      next,
      xpEarned: completed && !wasCompleted ? chapterCompletedXp : 0,
      completedChapterAdded: completed && !wasCompleted,
    );

    return saveProgress(next);
  }

  Future<void> saveAudioProgress(int chapterNum, Duration position) {
    final progress = getProgress();
    final audioProgress = Map<int, Duration>.from(progress.audioProgress);
    audioProgress[chapterNum] = position;
    return saveProgress(progress.copyWith(audioProgress: audioProgress));
  }

  Duration audioProgressFor(int chapterNum) {
    return getProgress().audioProgress[chapterNum] ?? Duration.zero;
  }

  WeeklyReport currentWeeklyReport() {
    final progress = getProgress();
    final weekStart = _startOfWeek(DateTime.now());
    return progress.weeklyReports.firstWhere(
      (report) => _isSameDay(report.weekStart, weekStart),
      orElse: () => WeeklyReport(
        weekStart: weekStart,
        xpEarned: 0,
        chaptersCompleted: 0,
        activeDays: progress.lastActiveDate == null ? 0 : 1,
      ),
    );
  }

  UserProgress _recordActivity(
    UserProgress progress, {
    required int xpEarned,
    bool completedChapterAdded = false,
  }) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final lastActive = progress.lastActiveDate == null
        ? null
        : DateTime(
            progress.lastActiveDate!.year,
            progress.lastActiveDate!.month,
            progress.lastActiveDate!.day,
          );

    var currentStreak = progress.currentStreak;
    if (lastActive == null) {
      currentStreak = 1;
    } else if (_isSameDay(lastActive, todayOnly)) {
      currentStreak = progress.currentStreak == 0 ? 1 : progress.currentStreak;
    } else if (_isSameDay(
      lastActive.add(const Duration(days: 1)),
      todayOnly,
    )) {
      currentStreak = progress.currentStreak + 1;
    } else {
      currentStreak = 1;
    }

    final activeDayAdded = lastActive == null || !_isSameDay(lastActive, todayOnly);
    final weeklyReports = _updateWeeklyReports(
      progress.weeklyReports,
      xpEarned: xpEarned,
      completedChapterAdded: completedChapterAdded,
      activeDayAdded: activeDayAdded,
    );

    return progress.copyWith(
      currentStreak: currentStreak,
      longestStreak: currentStreak > progress.longestStreak
          ? currentStreak
          : progress.longestStreak,
      xp: progress.xp + xpEarned,
      lastActiveDate: todayOnly,
      weeklyReports: weeklyReports,
    );
  }

  List<WeeklyReport> _updateWeeklyReports(
    List<WeeklyReport> reports, {
    required int xpEarned,
    required bool completedChapterAdded,
    required bool activeDayAdded,
  }) {
    final weekStart = _startOfWeek(DateTime.now());
    final nextReports = List<WeeklyReport>.from(reports);
    final index = nextReports.indexWhere(
      (report) => _isSameDay(report.weekStart, weekStart),
    );

    final existing = index >= 0
        ? nextReports[index]
        : WeeklyReport(
            weekStart: weekStart,
            xpEarned: 0,
            chaptersCompleted: 0,
            activeDays: 0,
          );

    final updated = existing.copyWith(
      xpEarned: existing.xpEarned + xpEarned,
      chaptersCompleted: existing.chaptersCompleted +
          (completedChapterAdded ? 1 : 0),
      activeDays: existing.activeDays + (activeDayAdded ? 1 : 0),
    );

    if (index >= 0) {
      nextReports[index] = updated;
    } else {
      nextReports.add(updated);
    }

    nextReports.sort((a, b) => b.weekStart.compareTo(a.weekStart));
    return nextReports.take(12).toList();
  }

  bool isChapterCompleted(int chapterNum) {
    return getProgress().completedChapters.contains(chapterNum);
  }

  Stream<BoxEvent> watch() => _box.watch();
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
