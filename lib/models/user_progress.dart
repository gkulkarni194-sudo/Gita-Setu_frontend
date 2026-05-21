class WeeklyReport {
  const WeeklyReport({
    required this.weekStart,
    required this.xpEarned,
    required this.chaptersCompleted,
    required this.activeDays,
  });

  final DateTime weekStart;
  final int xpEarned;
  final int chaptersCompleted;
  final int activeDays;

  factory WeeklyReport.fromMap(Map<dynamic, dynamic> map) {
    return WeeklyReport(
      weekStart: _dateFromMap(map['weekStart']) ?? _startOfWeek(DateTime.now()),
      xpEarned: map['xpEarned'] as int? ?? 0,
      chaptersCompleted: map['chaptersCompleted'] as int? ?? 0,
      activeDays: map['activeDays'] as int? ?? 0,
    );
  }

  WeeklyReport copyWith({
    DateTime? weekStart,
    int? xpEarned,
    int? chaptersCompleted,
    int? activeDays,
  }) {
    return WeeklyReport(
      weekStart: weekStart ?? this.weekStart,
      xpEarned: xpEarned ?? this.xpEarned,
      chaptersCompleted: chaptersCompleted ?? this.chaptersCompleted,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'xpEarned': xpEarned,
      'chaptersCompleted': chaptersCompleted,
      'activeDays': activeDays,
    };
  }
}

class UserProgress {
  const UserProgress({
    required this.completedChapters,
    required this.currentStreak,
    required this.longestStreak,
    required this.xp,
    required this.weeklyReports,
    required this.audioProgress,
    this.lastOpenedChapter,
    this.lastActiveDate,
  });

  final List<int> completedChapters;
  final int currentStreak;
  final int longestStreak;
  final int xp;
  final int? lastOpenedChapter;
  final DateTime? lastActiveDate;
  final List<WeeklyReport> weeklyReports;
  final Map<int, Duration> audioProgress;

  factory UserProgress.initial() {
    return const UserProgress(
      completedChapters: [],
      currentStreak: 0,
      longestStreak: 0,
      xp: 0,
      weeklyReports: [],
      audioProgress: {},
    );
  }

  factory UserProgress.fromMap(Map<dynamic, dynamic> map) {
    final chapters = (map['completedChapters'] as List? ?? const [])
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    final reports = (map['weeklyReports'] as List? ?? const [])
        .whereType<Map>()
        .map((report) => WeeklyReport.fromMap(report))
        .toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));

    final progress = <int, Duration>{};
    final rawProgress = map['audioProgress'];
    if (rawProgress is Map) {
      rawProgress.forEach((key, value) {
        final chapter = int.tryParse(key.toString());
        final milliseconds = value is int ? value : int.tryParse('$value');
        if (chapter != null && milliseconds != null) {
          progress[chapter] = Duration(milliseconds: milliseconds);
        }
      });
    }

    return UserProgress(
      completedChapters: chapters,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      xp: map['xp'] as int? ?? 0,
      lastOpenedChapter: map['lastOpenedChapter'] as int?,
      lastActiveDate: _dateFromMap(map['lastActiveDate']),
      weeklyReports: reports,
      audioProgress: progress,
    );
  }

  UserProgress copyWith({
    List<int>? completedChapters,
    int? currentStreak,
    int? longestStreak,
    int? xp,
    int? lastOpenedChapter,
    DateTime? lastActiveDate,
    List<WeeklyReport>? weeklyReports,
    Map<int, Duration>? audioProgress,
  }) {
    return UserProgress(
      completedChapters: completedChapters ?? this.completedChapters,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xp: xp ?? this.xp,
      lastOpenedChapter: lastOpenedChapter ?? this.lastOpenedChapter,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      audioProgress: audioProgress ?? this.audioProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedChapters': completedChapters,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'xp': xp,
      'lastOpenedChapter': lastOpenedChapter,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'weeklyReports': weeklyReports.map((report) => report.toMap()).toList(),
      'audioProgress': audioProgress.map(
        (chapter, progress) => MapEntry('$chapter', progress.inMilliseconds),
      ),
    };
  }
}

DateTime? _dateFromMap(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}
