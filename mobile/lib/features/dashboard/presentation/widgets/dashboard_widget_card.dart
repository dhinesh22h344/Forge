import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/forge_flame.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_widget_type.dart';

/// Renders the body for a single dashboard widget type. Every branch has an
/// explicit empty state — this screen is what a brand-new account sees for
/// a while, since categories/habits (M4/M5) are built after this milestone.
class DashboardWidgetCard extends StatelessWidget {
  const DashboardWidgetCard({
    super.key,
    required this.type,
    required this.summary,
    this.onTap,
  });

  final DashboardWidgetType type;
  final DashboardSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(onTap: onTap, child: _body(context));
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case DashboardWidgetType.currentStreak:
        return _StreakRow(summary: summary);
      case DashboardWidgetType.bestStreak:
        return _StatRow(
          icon: Icons.emoji_events_rounded,
          label: 'Best Streak',
          value: summary.bestStreak == 0 ? '—' : '${summary.bestStreak} days',
          color: Colors.amber,
        );
      case DashboardWidgetType.todayProgress:
        return _TodayProgress(summary: summary);
      case DashboardWidgetType.weeklyProgress:
        return _WeeklyProgress(rates: summary.weeklyCompletionRates);
      case DashboardWidgetType.xpLevel:
        return _StatRow(
          icon: Icons.bolt_rounded,
          label: 'Level ${summary.level}',
          value: '${summary.xp} XP',
          color: theme.colorScheme.secondary,
        );
      case DashboardWidgetType.quickAdd:
        return _QuickAdd();
      case DashboardWidgetType.recentActivity:
        return _RecentActivity(items: summary.recentActivity);
      case DashboardWidgetType.upcomingReminders:
        return _UpcomingReminders(items: summary.upcomingReminders);
      case DashboardWidgetType.calendarPreview:
        return _CalendarPreview();
      case DashboardWidgetType.motivationalQuote:
        return const _MotivationalQuote();
      case DashboardWidgetType.dailyGoal:
        return _DailyGoal(goal: summary.dailyGoal);
    }
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ],
    );
  }
}

/// Same flame used in the dashboard header, just mini and unadorned — this
/// is what keeps "current streak" reading as the same identity mark
/// everywhere it shows up, not a one-off icon.
class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: ForgeFlame(
              intensity: summary.consistencyScore,
              size: 40,
              showAura: false,
              showSparks: false,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Streak', style: theme.textTheme.bodyMedium),
              Text(
                summary.currentStreak == 0
                    ? 'No streak yet'
                    : '${summary.currentStreak} days',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayProgress extends StatelessWidget {
  const _TodayProgress({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.todayTotal == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a habit to start tracking today.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }
    final ratio = summary.todayCompleted / summary.todayTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Progress",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) =>
                LinearProgressIndicator(value: value, minHeight: 8),
          ),
        ),
        const SizedBox(height: 8),
        Text('${summary.todayCompleted} / ${summary.todayTotal} completed'),
      ],
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.rates});
  final List<double> rates;
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = rates.any((r) => r > 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Progress', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        if (!hasData)
          Text(
            'Your week will fill in as you complete habits.',
            style: theme.textTheme.bodyMedium,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Container(
                    height: 48,
                    width: 12,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.02, end: rates[i].clamp(0.05, 1.0)),
                      duration: Duration(milliseconds: 500 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => FractionallySizedBox(
                        heightFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_labels[i], style: theme.textTheme.bodySmall),
                ],
              );
            }),
          ),
      ],
    );
  }
}

class _QuickAdd extends StatelessWidget {
  // Navigates into the habit-creation flow once Milestone 5 ships; the card
  // is interactive now (see ForgeCard.onTap wiring in the screen) so it
  // doesn't need to be rebuilt when that lands.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.add_circle_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Quick Add Habit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.items});
  final List<RecentActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Completed habits will show up here.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final item in items.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item.habitName)),
                Text(
                  DateFormat.jm().format(item.completedAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _UpcomingReminders extends StatelessWidget {
  const _UpcomingReminders({required this.items});
  final List<UpcomingReminderItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Reminders', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('No reminders scheduled.', style: theme.textTheme.bodyMedium),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming Reminders', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final item in items.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item.habitName)),
                Text(
                  DateFormat.jm().format(item.scheduledAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalendarPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMM().format(now),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Full calendar with completion history is available once you have tracked habits.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MotivationalQuote extends StatelessWidget {
  const _MotivationalQuote();

  static const _quotes = [
    'Small steps, repeated daily, build the biggest changes.',
    'You do not rise to the level of your goals; you fall to the level of your systems.',
    'Discipline is choosing between what you want now and what you want most.',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().day % _quotes.length];
    return Text(
      '"$quote"',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal({required this.goal});
  final DailyGoal? goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (goal == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Goal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Set a daily goal from Settings once you have habits.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Goal', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '${goal!.completed} / ${goal!.target}',
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
