class ReportOverview {
  const ReportOverview({
    required this.totalCompletions,
    required this.totalMissed,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.xpEarned,
    required this.level,
    required this.activeHabitCount,
  });

  final int totalCompletions;
  final int totalMissed;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final int xpEarned;
  final int level;
  final int activeHabitCount;

  static const empty = ReportOverview(
    totalCompletions: 0,
    totalMissed: 0,
    completionRate: 0,
    currentStreak: 0,
    bestStreak: 0,
    xpEarned: 0,
    level: 1,
    activeHabitCount: 0,
  );
}
