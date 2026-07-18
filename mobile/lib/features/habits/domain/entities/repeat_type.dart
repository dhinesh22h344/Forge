enum RepeatType {
  daily,
  weekdays,
  weekends,
  specificDays,
  monthly,
  yearly,
  custom;

  /// Matches the backend's `repeat_type` column values exactly — see
  /// RepeatScheduleEvaluator on the backend for how each is interpreted.
  String get wireValue {
    switch (this) {
      case RepeatType.daily:
        return 'DAILY';
      case RepeatType.weekdays:
        return 'WEEKDAYS';
      case RepeatType.weekends:
        return 'WEEKENDS';
      case RepeatType.specificDays:
        return 'SPECIFIC_DAYS';
      case RepeatType.monthly:
        return 'MONTHLY';
      case RepeatType.yearly:
        return 'YEARLY';
      case RepeatType.custom:
        return 'CUSTOM';
    }
  }

  String get label {
    switch (this) {
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekdays:
        return 'Weekdays';
      case RepeatType.weekends:
        return 'Weekends';
      case RepeatType.specificDays:
        return 'Specific Days';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
      case RepeatType.custom:
        return 'Custom Schedule';
    }
  }

  static RepeatType fromWireValue(String value) {
    return RepeatType.values.firstWhere((r) => r.wireValue == value, orElse: () => RepeatType.daily);
  }
}
