import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/achievement_repository_impl.dart';
import '../../domain/entities/achievement.dart';

class AchievementsController extends AsyncNotifier<List<Achievement>> {
  @override
  Future<List<Achievement>> build() async {
    final repository = ref.watch(achievementRepositoryProvider);
    final result = await repository.list();
    return result.when(success: (achievements) => achievements, failure: (_) => const []);
  }
}

final achievementsControllerProvider = AsyncNotifierProvider<AchievementsController, List<Achievement>>(
  AchievementsController.new,
);
