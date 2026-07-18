import '../../../../core/error/result.dart';
import '../entities/category_performance.dart';
import '../entities/heatmap_day.dart';
import '../entities/report_overview.dart';
import '../entities/report_range.dart';
import '../entities/weekday_stat.dart';

abstract class ReportRepository {
  Future<Result<ReportOverview>> overview(ReportRange range);
  Future<Result<List<HeatmapDay>>> heatmap(ReportRange range);
  Future<Result<List<CategoryPerformance>>> categoryPerformance(ReportRange range);
  Future<Result<List<WeekdayStat>>> weekdayBreakdown(ReportRange range);
}
