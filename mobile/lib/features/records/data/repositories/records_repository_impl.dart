import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/personal_records.dart';
import '../../domain/repositories/records_repository.dart';
import '../datasources/records_remote_data_source.dart';

class RecordsRepositoryImpl implements RecordsRepository {
  const RecordsRepositoryImpl(this._remote);
  final RecordsRemoteDataSource _remote;

  @override
  Future<Result<PersonalRecords>> get() async {
    try {
      return Success(await _remote.get());
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

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  return RecordsRepositoryImpl(ref.watch(recordsRemoteDataSourceProvider));
});
