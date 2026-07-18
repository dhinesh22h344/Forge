import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class HabitRemoteDataSource {
  const HabitRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<HabitModel>> list({String? categoryId, bool? archived}) async {
    final response = await _client.dio.get('/habits', queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (archived != null) 'archived': archived,
    });
    return (response.data as List).map((e) => HabitModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HabitModel> create(Map<String, dynamic> body) async {
    final response = await _client.dio.post('/habits', data: body);
    return HabitModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<HabitModel> update(String id, Map<String, dynamic> body) async {
    final response = await _client.dio.put('/habits/$id', data: body);
    return HabitModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> setArchived(String id, bool archived) async {
    await _client.dio.patch('/habits/$id/${archived ? 'archive' : 'unarchive'}');
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/habits/$id');
  }

  Future<List<HabitLogModel>> logs(String habitId) async {
    final response = await _client.dio.get('/habits/$habitId/logs');
    return (response.data as List).map((e) => HabitLogModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HabitLogModel> upsertLog(String habitId, Map<String, dynamic> body) async {
    final response = await _client.dio.post('/habits/$habitId/logs', data: body);
    return HabitLogModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<HabitStreakModel> streak(String habitId) async {
    final response = await _client.dio.get('/habits/$habitId/logs/streak');
    return HabitStreakModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>((ref) {
  return HabitRemoteDataSource(ref.watch(apiClientProvider));
});
