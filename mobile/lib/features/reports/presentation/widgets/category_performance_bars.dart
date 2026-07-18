import 'package:flutter/material.dart';

import '../../domain/entities/category_performance.dart';

class CategoryPerformanceBars extends StatelessWidget {
  const CategoryPerformanceBars({super.key, required this.items});

  final List<CategoryPerformance> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.categoryName, style: theme.textTheme.bodyMedium)),
                    Text('${(item.completionRate * 100).round()}%', style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: item.completionRate.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(_parseColor(item.color)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _parseColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}
