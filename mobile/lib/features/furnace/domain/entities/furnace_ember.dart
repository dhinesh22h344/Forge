/// A habit currently sitting in The Furnace — a missed scheduled day still
/// within its grace window (through the end of the day after the miss).
/// [recoverable] is false when the grace window is fine but the 30-day
/// reforge cooldown ([cooldownEndsAt]) hasn't cleared yet.
class FurnaceEmber {
  const FurnaceEmber({
    required this.habitId,
    required this.habitName,
    required this.habitColor,
    this.habitIcon,
    this.habitEmoji,
    required this.missedDate,
    required this.graceDeadline,
    required this.recoverable,
    this.cooldownEndsAt,
  });

  final String habitId;
  final String habitName;
  final String habitColor;
  final String? habitIcon;
  final String? habitEmoji;
  final DateTime missedDate;
  final DateTime graceDeadline;
  final bool recoverable;
  final DateTime? cooldownEndsAt;
}

class FurnaceReforgeResult {
  const FurnaceReforgeResult({
    required this.habitId,
    required this.recoveredDate,
    required this.currentStreak,
    required this.bestStreak,
  });

  final String habitId;
  final DateTime recoveredDate;
  final int currentStreak;
  final int bestStreak;
}
