import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/habit_log.dart';

/// Full month calendar for a single habit — the "calendar day view" gap
/// noted for Milestone 6 (the 14-day strip next to this only shows a
/// recent-history glance, not a real calendar).
class HabitCalendarMonth extends StatefulWidget {
  const HabitCalendarMonth({super.key, required this.logs, required this.color});

  final List<HabitLog> logs;
  final Color color;

  @override
  State<HabitCalendarMonth> createState() => _HabitCalendarMonthState();
}

class _HabitCalendarMonthState extends State<HabitCalendarMonth> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusByDay = <String, HabitLogStatus>{for (final log in widget.logs) _key(log.logDate): log.status};

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = (firstOfMonth.weekday - DateTime.monday) % 7;
    final today = DateTime.now();

    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var day = 1; day <= daysInMonth; day++) DateTime(_visibleMonth.year, _visibleMonth.month, day),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1)),
            ),
            Text(DateFormat.yMMMM().format(_visibleMonth), style: theme.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Expanded(child: Center(child: Text(label, style: theme.textTheme.bodySmall)))],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemBuilder: (context, i) {
            final day = cells[i];
            if (day == null) return const SizedBox.shrink();
            final status = statusByDay[_key(day)];
            final isToday = _key(day) == _key(today);

            Color background;
            Color textColor = theme.colorScheme.onSurface;
            if (status == HabitLogStatus.completed) {
              background = widget.color;
              textColor = Colors.white;
            } else if (status == HabitLogStatus.missed) {
              background = theme.colorScheme.error.withValues(alpha: 0.35);
            } else {
              background = theme.colorScheme.onSurface.withValues(alpha: 0.06);
            }

            return AspectRatio(
              aspectRatio: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                ),
                child: Text('${day.day}', style: theme.textTheme.bodySmall?.copyWith(color: textColor)),
              ),
            );
          },
        ),
      ],
    );
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
