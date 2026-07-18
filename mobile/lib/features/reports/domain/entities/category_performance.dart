class CategoryPerformance {
  const CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.habitCount,
    required this.totalCompletions,
    required this.totalScheduled,
    required this.completionRate,
  });

  final String categoryId;
  final String categoryName;
  final String color;
  final int habitCount;
  final int totalCompletions;
  final int totalScheduled;
  final double completionRate;
}
