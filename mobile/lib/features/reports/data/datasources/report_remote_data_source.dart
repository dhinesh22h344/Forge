import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/report_range.dart';
import '../models/report_models.dart';

class ReportRemoteDataSource {
  const ReportRemoteDataSource(this._client);
  final ApiClient _client;

  Future<ReportOverviewModel> overview(ReportRange range) async {
    final response = await _client.dio.get('/reports/overview', queryParameters: {'range': range.apiValue});
    return ReportOverviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<HeatmapDayModel>> heatmap(ReportRange range) async {
    final response = await _client.dio.get('/reports/heatmap', queryParameters: {'range': range.apiValue});
    return (response.data as List).map((e) => HeatmapDayModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CategoryPerformanceModel>> categoryPerformance(ReportRange range) async {
    final response = await _client.dio.get('/reports/category-performance', queryParameters: {'range': range.apiValue});
    return (response.data as List).map((e) => CategoryPerformanceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WeekdayStatModel>> weekdayBreakdown(ReportRange range) async {
    final response = await _client.dio.get('/reports/weekday-breakdown', queryParameters: {'range': range.apiValue});
    return (response.data as List).map((e) => WeekdayStatModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSource(ref.watch(apiClientProvider));
});
