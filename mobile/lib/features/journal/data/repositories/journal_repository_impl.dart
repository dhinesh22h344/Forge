import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_data_source.dart';

class JournalRepositoryImpl implements JournalRepository {
  const JournalRepositoryImpl(this._remote);
  final JournalRemoteDataSource _remote;

  @override
  Future<Result<List<JournalEntry>>> list({DateTime? from, DateTime? to}) async {
    try {
      return Success(await _remote.list(from: from, to: to));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<JournalEntry>> get(DateTime date) async {
    try {
      return Success(await _remote.get(date));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<JournalEntry>> upsert({
    required DateTime date,
    required String content,
    JournalMood? mood,
  }) async {
    try {
      final entry = await _remote.upsert(date, {
        'content': content,
        'mood': mood?.wireValue,
      });
      return Success(entry);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> delete(DateTime date) async {
    try {
      await _remote.delete(date);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) return const UnauthorizedFailure();
    if (response.statusCode == 404) return const UnknownFailure('No entry for this day yet');
    if (response.statusCode == 400) {
      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      return ValidationFailure(message ?? 'Please check your input');
    }
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalRemoteDataSourceProvider));
});
