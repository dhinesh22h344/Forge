import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

class CategoriesController extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(categoryRepositoryProvider);
    final result = await ListCategoriesUseCase(repository).call();
    return result.when(success: (categories) => categories, failure: (_) => const []);
  }

  Future<Failure?> create({
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) async {
    final repository = ref.read(categoryRepositoryProvider);
    final result = await CreateCategoryUseCase(repository)
        .call(name: name, color: color, gradient: gradient, icon: icon, description: description);
    return result.when(
      success: (category) {
        state = AsyncData([...state.value ?? [], category]);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> updateCategory({
    required String id,
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) async {
    final repository = ref.read(categoryRepositoryProvider);
    final result = await UpdateCategoryUseCase(repository)
        .call(id: id, name: name, color: color, gradient: gradient, icon: icon, description: description);
    return result.when(
      success: (updated) {
        state = AsyncData([for (final c in state.value ?? []) if (c.id == id) updated else c]);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> delete(String id) async {
    final repository = ref.read(categoryRepositoryProvider);
    final result = await DeleteCategoryUseCase(repository).call(id);
    return result.when(
      success: (_) {
        state = AsyncData([for (final c in state.value ?? []) if (c.id != id) c]);
        return null;
      },
      failure: (failure) => failure,
    );
  }
}

final categoriesControllerProvider = AsyncNotifierProvider<CategoriesController, List<Category>>(
  CategoriesController.new,
);
