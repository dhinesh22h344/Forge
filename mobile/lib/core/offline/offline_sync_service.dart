import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/providers/dashboard_controller.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/habits/domain/entities/habit_log.dart';
import '../../features/habits/presentation/providers/habits_controller.dart';
import 'offline_queue.dart';

/// Replays queued habit check-offs once connectivity returns, and once at
/// startup in case the app was closed while still offline. Only this one
/// action type is queued (see `OfflineQueue` doc) — a failed replay is left
/// in the queue for the next attempt rather than surfaced as an error, since
/// there's no screen actively waiting on it.
class OfflineSyncService {
  OfflineSyncService(this._ref);
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void start() {
    flush();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) flush();
    });
  }

  Future<void> flush() async {
    final queue = _ref.read(offlineQueueProvider);
    final pending = await queue.readAll();
    if (pending.isEmpty) return;

    final repository = _ref.read(habitRepositoryProvider);
    var syncedAny = false;
    for (final entry in pending) {
      final result = await repository.upsertLog(
        habitId: entry.habitId,
        logDate: DateTime.parse(entry.logDate),
        status: HabitLogStatus.fromWireValue(entry.status),
      );
      if (result.isSuccess) {
        await queue.remove(entry.habitId, entry.logDate);
        syncedAny = true;
      }
      // Still offline (or a real server error) — leave it queued for the
      // next reconnect/startup rather than retrying in a tight loop here.
    }

    if (syncedAny) {
      _ref.invalidate(habitsControllerProvider);
      _ref.invalidate(dashboardControllerProvider);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(ref);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});
