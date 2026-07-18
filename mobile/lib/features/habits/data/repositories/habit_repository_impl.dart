import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(this._remote);
  final HabitRemoteDataSource _remote;

  @override
  Future<Result<List<Habit>>> list({String? categoryId, bool? archived}) async {
    try {
      return Success(await _remote.list(categoryId: categoryId, archived: archived));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<Habit>> create(HabitDraft draft) async {
    try {
      return Success(await _remote.create(HabitModel.draftToJson(draft)));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<Habit>> update(String id, HabitDraft draft) async {
    try {
      return Success(await _remote.update(id, HabitModel.draftToJson(draft)));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> archive(String id, {required bool archived}) async {
    try {
      await _remote.setArchived(id, archived);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<List<HabitLog>>> logs(String habitId) async {
    try {
      return Success(await _remote.logs(habitId));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<HabitLog>> upsertLog({
    required String habitId,
    required DateTime logDate,
    required HabitLogStatus status,
    double? progressValue,
    String? notes,
  }) async {
    try {
      final body = {
        'logDate': logDate.toIso8601String().split('T').first,
        'status': status.wireValue,
        'progressValue': progressValue,
        'notes': notes,
      };
      return Success(await _remote.upsertLog(habitId, body));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<HabitStreak>> streak(String habitId) async {
    try {
      return Success(await _remote.streak(habitId));
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) return const UnauthorizedFailure();
    if (response.statusCode == 404) return const ServerFailure('Not found', statusCode: 404);
    if (response.statusCode == 400) {
      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      return ValidationFailure(message ?? 'Please check your input');
    }
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(habitRemoteDataSourceProvider));
});
