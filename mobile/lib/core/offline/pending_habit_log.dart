/// A habit check-off that couldn't reach the server yet. Keyed by
/// (habitId, logDate) — only the latest status per key is ever kept, so
/// toggling a habit off/on/off while offline queues one entry, not three.
class PendingHabitLog {
  const PendingHabitLog({required this.habitId, required this.logDate, required this.status});

  final String habitId;

  /// `YYYY-MM-DD`, matching the wire format `upsertLog` already sends.
  final String logDate;

  /// Wire value, e.g. `COMPLETED` / `SKIPPED` — see `HabitLogStatus.wireValue`.
  final String status;

  String get key => '$habitId|$logDate';

  Map<String, dynamic> toJson() => {'habitId': habitId, 'logDate': logDate, 'status': status};

  factory PendingHabitLog.fromJson(Map<String, dynamic> json) => PendingHabitLog(
        habitId: json['habitId'] as String,
        logDate: json['logDate'] as String,
        status: json['status'] as String,
      );
}
