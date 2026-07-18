import '../../../../core/error/result.dart';
import '../entities/dashboard_summary.dart';
import '../entities/dashboard_widget_config.dart';

abstract class DashboardRepository {
  Future<Result<DashboardSummary>> getSummary();

  Future<Result<List<DashboardWidgetConfig>>> getWidgetLayout();

  Future<Result<void>> saveWidgetLayout(List<DashboardWidgetConfig> layout);
}
