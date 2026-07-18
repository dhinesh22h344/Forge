enum ReportRange {
  week,
  month,
  year,
  all;

  String get label {
    switch (this) {
      case ReportRange.week:
        return 'Week';
      case ReportRange.month:
        return 'Month';
      case ReportRange.year:
        return 'Year';
      case ReportRange.all:
        return 'All time';
    }
  }

  /// Matches the backend's `ReportRange` enum constant names exactly.
  String get apiValue => name.toUpperCase();
}
