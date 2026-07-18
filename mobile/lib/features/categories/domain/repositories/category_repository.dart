import '../../../../core/error/result.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> list();

  Future<Result<Category>> create({
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  });

  Future<Result<Category>> update({
    required String id,
    required String name,
    required String color,
    String? gradient,
    required String icon,
    String? description,
  });

  Future<Result<void>> delete(String id);
}
