import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/icon_catalog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../domain/entities/personal_records.dart';
import '../providers/records_controller.dart';

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records')),
      body: recordsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load your records'),
          onRetry: () => ref.invalidate(recordsControllerProvider),
        ),
        data: (records) {
          if (records.totalCompletionsAllTime == 0) {
            return const EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'No records yet',
              message: 'Complete habits to start setting personal bests.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RecordsGrid(records: records),
              const SizedBox(height: 20),
              Text('Habit Leaderboard', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              for (var i = 0; i < records.perHabitRecords.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StaggeredFadeIn(index: i, child: _HabitRecordRow(rank: i + 1, record: records.perHabitRecords[i])),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordsGrid extends StatelessWidget {
  const _RecordsGrid({required this.records});
  final PersonalRecords records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      (
        Icons.local_fire_department_rounded,
        'Best Streak Ever',
        '${records.bestStreakEver}d',
        records.bestStreakHabitName,
      ),
      (Icons.diamond_rounded, 'Best Perfect-Day Streak', '${records.bestPerfectDayStreakEver}d', null),
      (Icons.check_circle_rounded, 'Total Completions', '${records.totalCompletionsAllTime}', null),
      (
        Icons.star_rounded,
        'Best Single Day',
        '${records.bestSingleDayCompletions}',
        records.bestSingleDayDate == null ? null : DateFormat.yMMMd().format(records.bestSingleDayDate!),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, i) {
        final (icon, label, value, subtitle) = tiles[i];
        return ForgeCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              Text(value, style: theme.textTheme.headlineSmall),
              if (subtitle != null)
                Text(subtitle, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        );
      },
    );
  }
}

class _HabitRecordRow extends StatelessWidget {
  const _HabitRecordRow({required this.rank, required this.record});

  final int rank;
  final HabitRecord record;

  Color get _color => Color(int.parse('FF${record.habitColor.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForgeCard(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('#$rank', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: record.habitEmoji != null
                ? Text(record.habitEmoji!, style: const TextStyle(fontSize: 16))
                : Icon(IconCatalog.resolve(record.habitIcon), color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.habitName, style: theme.textTheme.titleSmall),
                Text(
                  '${record.bestStreak}d best streak · ${record.totalCompletions} completions',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
