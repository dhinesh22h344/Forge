import '../../../../core/error/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class ListCategoriesUseCase {
  const ListCategoriesUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<List<Category>>> call() => _repository.list();
}

class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<Category>> call({
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) {
    return _repository.create(name: name, color: color, gradient: gradient, icon: icon, description: description);
  }
}

class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<Category>> call({
    required String id,
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  }) {
    return _repository.update(id: id, name: name, color: color, gradient: gradient, icon: icon, description: description);
  }
}

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);
  final CategoryRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}
