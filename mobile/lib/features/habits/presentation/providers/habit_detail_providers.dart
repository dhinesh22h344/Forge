import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit_log.dart';

final habitStreakProvider = FutureProvider.family<HabitStreak, String>((ref, habitId) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.streak(habitId);
  return result.when(success: (s) => s, failure: (_) => const HabitStreak(currentStreak: 0, bestStreak: 0));
});

final habitLogsProvider = FutureProvider.family<List<HabitLog>, String>((ref, habitId) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.logs(habitId);
  return result.when(success: (logs) => logs, failure: (_) => const []);
});
