import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habit_detail_providers.dart';
import '../providers/habits_controller.dart';
import '../widgets/habit_calendar_month.dart';
import '../widgets/milestone_celebration.dart';
import '../widgets/reminders_section.dart';
import 'create_habit_screen.dart';

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  Color get _color => Color(int.parse('FF${habit.color.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streakAsync = ref.watch(habitStreakProvider(habit.id));
    final logsAsync = ref.watch(habitLogsProvider(habit.id));
    final todayStatus = ref.watch(habitsControllerProvider).value?.todayStatusByHabitId[habit.id];
    final isCompletedToday = todayStatus == HabitLogStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CreateHabitScreen(editing: habit))),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () async {
              await ref.read(habitsControllerProvider.notifier).archiveHabit(habit.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (habit.description != null) ...[
              Text(habit.description!, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ForgeCard(
                    child: streakAsync.when(
                      loading: () => const LoadingView(compact: true),
                      error: (_, __) => const Text('—'),
                      data: (streak) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Streak', style: theme.textTheme.bodyMedium),
                          Text('${streak.currentStreak} days', style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ForgeCard(
                    child: streakAsync.when(
                      loading: () => const LoadingView(compact: true),
                      error: (_, __) => const Text('—'),
                      data: (streak) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Best Streak', style: theme.textTheme.bodyMedium),
                          Text('${streak.bestStreak} days', style: theme.textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CompleteButton(
              isCompleted: isCompletedToday,
              color: _color,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final wasCompleted = isCompletedToday;
                final failure = await ref.read(habitsControllerProvider.notifier).toggleToday(habit.id);
                ref.invalidate(habitStreakProvider(habit.id));
                ref.invalidate(habitLogsProvider(habit.id));
                if (failure == null && !wasCompleted && context.mounted) {
                  await maybeCelebrateMilestone(context, ref, habitId: habit.id, habitName: habit.name);
                }
              },
            ),
            const SizedBox(height: 24),
            Text('Last 14 Days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            logsAsync.when(
              loading: () => const LoadingView(compact: true),
              error: (_, __) => const Text('—'),
              data: (logs) => _LogHistoryStrip(logs: logs, color: _color),
            ),
            const SizedBox(height: 24),
            Text('Calendar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            logsAsync.when(
              loading: () => const LoadingView(compact: true),
              error: (_, __) => const Text('—'),
              data: (logs) => ForgeCard(child: HabitCalendarMonth(logs: logs, color: _color)),
            ),
            const SizedBox(height: 24),
            RemindersSection(habit: habit),
            if (habit.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Tags', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [for (final t in habit.tags) Chip(label: Text(t))]),
            ],
            if (habit.notes != null) ...[
              const SizedBox(height: 24),
              Text('Notes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(habit.notes!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogHistoryStrip extends StatelessWidget {
  const _LogHistoryStrip({required this.logs, required this.color});

  final List<HabitLog> logs;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final statusByDay = <String, HabitLogStatus>{
      for (final log in logs) _dateKey(log.logDate): log.status,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(14, (i) {
        final date = today.subtract(Duration(days: 13 - i));
        final status = statusByDay[_dateKey(date)];
        Color boxColor;
        if (status == HabitLogStatus.completed) {
          boxColor = color;
        } else if (status == HabitLogStatus.missed) {
          boxColor = theme.colorScheme.error.withValues(alpha: 0.4);
        } else {
          boxColor = theme.colorScheme.onSurface.withValues(alpha: 0.08);
        }
        return Container(
          width: 18,
          height: 28,
          decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(6)),
        );
      }),
    );
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

/// Plays a quick scale pop when [isCompleted] flips false → true, on top of
/// the haptic feedback the caller already fires — a bare state swap felt
/// flat for what should be the single most rewarding tap in the app.
class _CompleteButton extends StatefulWidget {
  const _CompleteButton({required this.isCompleted, required this.color, required this.onPressed});

  final bool isCompleted;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_CompleteButton> createState() => _CompleteButtonState();
}

class _CompleteButtonState extends State<_CompleteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant _CompleteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isCompleted && widget.isCompleted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: widget.isCompleted ? widget.color : null),
          onPressed: widget.onPressed,
          icon: Icon(widget.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
          label: Text(widget.isCompleted ? 'Completed Today' : 'Mark Complete'),
        ),
      ),
    );
  }
}
