import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/records_repository_impl.dart';
import '../../domain/entities/personal_records.dart';

class RecordsController extends AsyncNotifier<PersonalRecords> {
  @override
  Future<PersonalRecords> build() async {
    final repository = ref.watch(recordsRepositoryProvider);
    final result = await repository.get();
    return result.when(
      success: (records) => records,
      failure: (_) => const PersonalRecords(
        totalCompletionsAllTime: 0,
        bestStreakEver: 0,
        bestPerfectDayStreakEver: 0,
        bestSingleDayCompletions: 0,
        perHabitRecords: [],
      ),
    );
  }
}

final recordsControllerProvider = AsyncNotifierProvider<RecordsController, PersonalRecords>(
  RecordsController.new,
);
