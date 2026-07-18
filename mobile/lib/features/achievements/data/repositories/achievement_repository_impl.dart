import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/achievement_remote_data_source.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  const AchievementRepositoryImpl(this._remote);
  final AchievementRemoteDataSource _remote;

  @override
  Future<Result<List<Achievement>>> list() async {
    try {
      return Success(await _remote.list());
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

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepositoryImpl(ref.watch(achievementRemoteDataSourceProvider));
});
