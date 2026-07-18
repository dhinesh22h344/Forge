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
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        items[i].categoryName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${(items[i].completionRate * 100).round()}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: items[i].completionRate.clamp(0.0, 1.0),
                    ),
                    duration: Duration(milliseconds: 500 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      valueColor: AlwaysStoppedAnimation(
                        _parseColor(items[i].color),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _parseColor(String hex) =>
      Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}
