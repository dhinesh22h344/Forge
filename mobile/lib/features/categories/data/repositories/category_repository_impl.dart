import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);
  final CategoryRemoteDataSource _remote;

  @override
  Future<Result<List<Category>>> list() async {
    try {
      return Success(await _remote.list());
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<Category>> create({
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) async {
    try {
      final category = await _remote.create({
        'name': name,
        'color': color,
        'gradient': gradient,
        'icon': icon,
        'description': description,
      });
      return Success(category);
    } on DioException catch (e) {
      return Error(_mapError(e));
    }
  }

  @override
  Future<Result<Category>> update({
    required String id,
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) async {
    try {
      final category = await _remote.update(id, {
        'name': name,
        'color': color,
        'gradient': gradient,
        'icon': icon,
        'description': description,
      });
      return Success(category);
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

  Failure _mapError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) return const UnauthorizedFailure();
    if (response.statusCode == 400) {
      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      return ValidationFailure(message ?? 'Please check your input');
    }
    return ServerFailure('Something went wrong', statusCode: response.statusCode);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryRemoteDataSourceProvider));
});
