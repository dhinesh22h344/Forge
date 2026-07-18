import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/category_performance.dart';
import '../../domain/entities/heatmap_day.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/entities/report_range.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._remote);
  final ReportRemoteDataSource _remote;

  @override
  Future<Result<ReportOverview>> overview(ReportRange range) async {
    try {
      return Success(await _remote.overview(range));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<List<HeatmapDay>>> heatmap(ReportRange range) async {
    try {
      return Success(await _remote.heatmap(range));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<List<CategoryPerformance>>> categoryPerformance(ReportRange range) async {
    try {
      return Success(await _remote.categoryPerformance(range));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<List<WeekdayStat>>> weekdayBreakdown(ReportRange range) async {
    try {
      return Success(await _remote.weekdayBreakdown(range));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) return const UnauthorizedFailure();
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(reportRemoteDataSourceProvider));
});
