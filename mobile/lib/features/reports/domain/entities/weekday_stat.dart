class WeekdayStat {
  const WeekdayStat({required this.weekday, required this.completionRate});

  /// 3-letter abbreviation, MON..SUN — matches the backend's ordering.
  final String weekday;
  final double completionRate;
}
