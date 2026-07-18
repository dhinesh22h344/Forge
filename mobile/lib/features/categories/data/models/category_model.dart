import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.color,
    super.gradient,
    required super.icon,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      gradient: json['gradient'] as String?,
      icon: json['icon'] as String,
      description: json['description'] as String?,
    );
  }
}
