import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/category_performance.dart';
import '../../domain/entities/heatmap_day.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/weekday_stat.dart';

final reportRangeProvider = StateProvider<ReportRange>((ref) => ReportRange.month);

class ReportsState {
  const ReportsState({
    required this.overview,
    required this.heatmap,
    required this.categoryPerformance,
    required this.weekdayStats,
  });

  final ReportOverview overview;
  final List<HeatmapDay> heatmap;
  final List<CategoryPerformance> categoryPerformance;
  final List<WeekdayStat> weekdayStats;
}

/// Rebuilds whenever [reportRangeProvider] changes — the range selector on
/// [ReportsScreen] just writes to that provider, it never touches this
/// controller directly.
class ReportsController extends AsyncNotifier<ReportsState> {
  @override
  Future<ReportsState> build() async {
    final range = ref.watch(reportRangeProvider);
    final repository = ref.watch(reportRepositoryProvider);

    final results = await Future.wait([
      repository.overview(range),
      repository.heatmap(range),
      repository.categoryPerformance(range),
      repository.weekdayBreakdown(range),
    ]);

    final overview = results[0].when(success: (v) => v as ReportOverview, failure: (_) => ReportOverview.empty);
    final heatmap = results[1].when(success: (v) => v as List<HeatmapDay>, failure: (_) => const <HeatmapDay>[]);
    final categoryPerformance =
        results[2].when(success: (v) => v as List<CategoryPerformance>, failure: (_) => const <CategoryPerformance>[]);
    final weekdayStats = results[3].when(success: (v) => v as List<WeekdayStat>, failure: (_) => const <WeekdayStat>[]);

    return ReportsState(
      overview: overview,
      heatmap: heatmap,
      categoryPerformance: categoryPerformance,
      weekdayStats: weekdayStats,
    );
  }
}

final reportsControllerProvider = AsyncNotifierProvider<ReportsController, ReportsState>(ReportsController.new);
