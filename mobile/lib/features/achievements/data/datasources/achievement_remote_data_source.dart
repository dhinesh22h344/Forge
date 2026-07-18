import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/achievement_model.dart';

class AchievementRemoteDataSource {
  const AchievementRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<AchievementModel>> list() async {
    final response = await _client.dio.get('/achievements');
    return (response.data as List).map((e) => AchievementModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final achievementRemoteDataSourceProvider = Provider<AchievementRemoteDataSource>((ref) {
  return AchievementRemoteDataSource(ref.watch(apiClientProvider));
});
