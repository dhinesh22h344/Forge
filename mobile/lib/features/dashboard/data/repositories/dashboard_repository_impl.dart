import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_widget_config.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_summary_model.dart';
import '../models/dashboard_widget_config_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);
  final DashboardRemoteDataSource _remote;

  @override
  Future<Result<DashboardSummary>> getSummary() async {
    try {
      final raw = await _remote.getSummaryRaw();
      return Success(DashboardSummaryModel.fromJson(raw));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<List<DashboardWidgetConfig>>> getWidgetLayout() async {
    try {
      final raw = await _remote.getWidgetLayoutRaw();
      if (raw.isEmpty) {
        // No saved layout yet — first login. Default layout is applied
        // client-side and persisted on first customization, not eagerly
        // written here, so an unmodified account never accrues writes.
        return Success(DashboardWidgetConfig.defaultLayout());
      }
      return Success(raw.map(DashboardWidgetConfigModel.fromJson).toList()..sort((a, b) => a.position.compareTo(b.position)));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> saveWidgetLayout(List<DashboardWidgetConfig> layout) async {
    try {
      await _remote.saveWidgetLayout(layout);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();
    if (status == 401) return const UnauthorizedFailure();
    return ServerFailure('Could not load dashboard', statusCode: status);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});
