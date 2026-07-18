import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_widget_config.dart';
import '../models/dashboard_widget_config_model.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> getSummaryRaw() async {
    final response = await _client.dio.get('/dashboard');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getWidgetLayoutRaw() async {
    final response = await _client.dio.get('/dashboard/widgets');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveWidgetLayout(List<DashboardWidgetConfig> layout) async {
    await _client.dio.put('/dashboard/widgets', data: layout.map(DashboardWidgetConfigModel.toJson).toList());
  }
}

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(apiClientProvider));
});
