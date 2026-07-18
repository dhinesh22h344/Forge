class Category {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.gradient,
    required this.icon,
    this.description,
  });

  final String id;
  final String name;
  final String color;
  final String? gradient;
  final String icon;
  final String? description;
}
