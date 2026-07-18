import 'package:flutter/material.dart';

import '../../domain/entities/heatmap_day.dart';

/// A GitHub-contribution-graph-style grid: one cell per day, color intensity
/// = completion rate. Leading blank cells pad the first day into its correct
/// Mon-Sun column so the 7-wide grid always reads as weekday columns.
class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({super.key, required this.days, required this.color});

  final List<HeatmapDay> days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final leadingBlanks = (days.first.date.weekday - DateTime.monday) % 7;
    final cells = <HeatmapDay?>[for (var i = 0; i < leadingBlanks; i++) null, ...days];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Expanded(child: Center(child: Text(label, style: theme.textTheme.bodySmall)))],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, i) {
            final cell = cells[i];
            if (cell == null) return const SizedBox.shrink();
            final intensity = cell.completionRate.clamp(0.0, 1.0);
            final cellColor = cell.scheduledCount == 0
                ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.15 + intensity * 0.75);
            return Tooltip(
              message: '${cell.date.year}-${cell.date.month.toString().padLeft(2, '0')}-${cell.date.day.toString().padLeft(2, '0')}: '
                  '${cell.completedCount}/${cell.scheduledCount}',
              child: AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: cellColor, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
