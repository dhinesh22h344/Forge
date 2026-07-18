import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/furnace_ember_model.dart';

class FurnaceRemoteDataSource {
  const FurnaceRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<FurnaceEmberModel>> listEmbers() async {
    final response = await _client.dio.get('/furnace');
    return (response.data as List).map((e) => FurnaceEmberModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FurnaceReforgeResultModel> reforge(String habitId) async {
    final response = await _client.dio.post('/habits/$habitId/furnace/reforge');
    return FurnaceReforgeResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final furnaceRemoteDataSourceProvider = Provider<FurnaceRemoteDataSource>((ref) {
  return FurnaceRemoteDataSource(ref.watch(apiClientProvider));
});
