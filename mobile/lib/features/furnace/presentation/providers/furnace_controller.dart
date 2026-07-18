import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../../habits/presentation/providers/habit_detail_providers.dart';
import '../../../habits/presentation/providers/habits_controller.dart';
import '../../data/repositories/furnace_repository_impl.dart';
import '../../domain/entities/furnace_ember.dart';
import '../../../../core/error/failure.dart';

class FurnaceController extends AsyncNotifier<List<FurnaceEmber>> {
  @override
  Future<List<FurnaceEmber>> build() async {
    final repository = ref.watch(furnaceRepositoryProvider);
    final result = await repository.listEmbers();
    return result.when(success: (embers) => embers, failure: (_) => const []);
  }

  /// Reforges one ember. On success, drops it from the list and refreshes
  /// everywhere its streak is shown — same invalidation set as a normal
  /// habit completion (see HabitsController.toggleToday).
  Future<Failure?> reforge(String habitId) async {
    final repository = ref.read(furnaceRepositoryProvider);
    final result = await repository.reforge(habitId);
    return result.when(
      success: (_) {
        final current = state.value;
        if (current != null) {
          state = AsyncData([for (final e in current) if (e.habitId != habitId) e]);
        }
        ref.invalidate(habitStreakProvider(habitId));
        ref.invalidate(habitLogsProvider(habitId));
        ref.invalidate(habitsControllerProvider);
        ref.invalidate(dashboardControllerProvider);
        return null;
      },
      failure: (failure) => failure,
    );
  }
}

final furnaceControllerProvider = AsyncNotifierProvider<FurnaceController, List<FurnaceEmber>>(
  FurnaceController.new,
);
