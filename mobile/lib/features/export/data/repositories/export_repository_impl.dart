import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_remote_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  const ExportRepositoryImpl(this._remote);
  final ExportRemoteDataSource _remote;

  @override
  Future<Result<Map<String, dynamic>>> export() async {
    try {
      return Success(await _remote.export());
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> importJson(Map<String, dynamic> payload) async {
    try {
      await _remote.importJson(payload);
      return const Success(null);
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
      return ValidationFailure(message ?? "That file doesn't look like a Forge backup");
    }
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepositoryImpl(ref.watch(exportRemoteDataSourceProvider));
});
