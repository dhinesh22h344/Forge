import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/furnace_ember.dart';
import '../../domain/repositories/furnace_repository.dart';
import '../datasources/furnace_remote_data_source.dart';

class FurnaceRepositoryImpl implements FurnaceRepository {
  const FurnaceRepositoryImpl(this._remote);
  final FurnaceRemoteDataSource _remote;

  @override
  Future<Result<List<FurnaceEmber>>> listEmbers() async {
    try {
      return Success(await _remote.listEmbers());
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<FurnaceReforgeResult>> reforge(String habitId) async {
    try {
      return Success(await _remote.reforge(habitId));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) return const UnauthorizedFailure();
    if (response.statusCode == 400) {
      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      return ValidationFailure(message ?? 'This habit can no longer be reforged');
    }
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final furnaceRepositoryProvider = Provider<FurnaceRepository>((ref) {
  return FurnaceRepositoryImpl(ref.watch(furnaceRemoteDataSourceProvider));
});
