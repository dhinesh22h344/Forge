class HeatmapDay {
  const HeatmapDay({
    required this.date,
    required this.scheduledCount,
    required this.completedCount,
    required this.completionRate,
  });

  final DateTime date;
  final int scheduledCount;
  final int completedCount;
  final double completionRate;
}
