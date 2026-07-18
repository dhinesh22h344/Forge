import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class ExportRemoteDataSource {
  const ExportRemoteDataSource(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> export() async {
    final response = await _client.dio.get('/export');
    return response.data as Map<String, dynamic>;
  }

  Future<void> importJson(Map<String, dynamic> payload) async {
    await _client.dio.post('/import', data: payload);
  }
}

final exportRemoteDataSourceProvider = Provider<ExportRemoteDataSource>((ref) {
  return ExportRemoteDataSource(ref.watch(apiClientProvider));
});
