import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../achievements/presentation/screens/achievements_screen.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/entities/report_range.dart';
import '../providers/reports_controller.dart';
import '../widgets/category_performance_bars.dart';
import '../widgets/heatmap_grid.dart';
import '../widgets/weekday_radar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsControllerProvider);
    final range = ref.watch(reportRangeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Achievements',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AchievementsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(reportsControllerProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ReportRange>(
              segments: [for (final r in ReportRange.values) ButtonSegment(value: r, label: Text(r.label))],
              selected: {range},
              onSelectionChanged: (selection) => ref.read(reportRangeProvider.notifier).state = selection.first,
            ),
            const SizedBox(height: 16),
            reportsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.only(top: 48), child: LoadingView()),
              error: (error, _) => ErrorView(
                failure: const UnknownFailure('Could not load reports'),
                onRetry: () => ref.invalidate(reportsControllerProvider),
              ),
              data: (state) {
                if (state.overview.activeHabitCount == 0 && state.heatmap.every((d) => d.scheduledCount == 0)) {
                  return const EmptyState(
                    icon: Icons.bar_chart_rounded,
                    title: 'Nothing to report yet',
                    message: 'Create and complete habits to see your stats build up here.',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OverviewGrid(overview: state.overview),
                    const SizedBox(height: 20),
                    ForgeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activity', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          HeatmapGrid(days: state.heatmap, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ForgeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('By Weekday', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          WeekdayRadarChart(stats: state.weekdayStats),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ForgeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category Performance', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          if (state.categoryPerformance.isEmpty)
                            Text('Create a category to see its performance here.', style: theme.textTheme.bodyMedium)
                          else
                            CategoryPerformanceBars(items: state.categoryPerformance),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.overview});
  final ReportOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      (Icons.check_circle_rounded, 'Completions', '${overview.totalCompletions}'),
      (Icons.percent_rounded, 'Completion Rate', '${(overview.completionRate * 100).round()}%'),
      (Icons.local_fire_department_rounded, 'Current Streak', '${overview.currentStreak}d'),
      (Icons.emoji_events_rounded, 'Best Streak', '${overview.bestStreak}d'),
      (Icons.bolt_rounded, 'XP Earned', '${overview.xpEarned}'),
      (Icons.checklist_rounded, 'Active Habits', '${overview.activeHabitCount}'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, i) {
        final (icon, label, value) = tiles[i];
        return ForgeCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    Text(value, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
