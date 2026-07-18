import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pending_habit_log.dart';

/// Persists habit check-offs that failed to reach the server so they survive
/// app restarts, and replays them once connectivity returns (see
/// `HabitsController`/`main.dart` for where `flush` is called). Scoped
/// deliberately to just this one action — see the Phase 1 plan note that
/// offline-first here means "the habit check-off action specifically", not a
/// general-purpose sync framework.
class OfflineQueue {
  static const _prefsKey = 'forge.offline_queue.habit_logs';

  /// Adds/replaces the entry for `entry.key` — queuing the same habit+date
  /// twice while offline (off, then back on) keeps only the latest status,
  /// not a growing backlog of intermediate toggles.
  Future<void> upsert(PendingHabitLog entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _readAll(prefs);
    entries[entry.key] = entry;
    await _writeAll(prefs, entries);
  }

  Future<void> remove(String habitId, String logDate) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _readAll(prefs);
    entries.remove('$habitId|$logDate');
    await _writeAll(prefs, entries);
  }

  Future<List<PendingHabitLog>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    return (await _readAll(prefs)).values.toList();
  }

  Future<Map<String, PendingHabitLog>> _readAll(SharedPreferences prefs) async {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as List;
    final entries = decoded.map((e) => PendingHabitLog.fromJson(e as Map<String, dynamic>));
    return {for (final e in entries) e.key: e};
  }

  Future<void> _writeAll(SharedPreferences prefs, Map<String, PendingHabitLog> entries) async {
    await prefs.setString(_prefsKey, jsonEncode(entries.values.map((e) => e.toJson()).toList()));
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) => OfflineQueue());
