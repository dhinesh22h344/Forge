import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_reminder.dart';
import '../../domain/repositories/habit_repository.dart';
import '../providers/habit_reminders_controller.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

class RemindersSection extends ConsumerWidget {
  const RemindersSection({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(habitRemindersControllerProvider(habit.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reminders', style: theme.textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        remindersAsync.when(
          loading: () => const LoadingView(compact: true),
          error: (_, __) => const Text('—'),
          data: (reminders) {
            if (reminders.isEmpty) {
              return Text(
                'No reminders yet — add one so you never miss this habit.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              );
            }
            return Column(
              children: [for (final r in reminders) _ReminderRow(habit: habit, reminder: r)],
            );
          },
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReminderEditorSheet(habit: habit),
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.habit, required this.reminder});

  final Habit habit;
  final HabitReminder reminder;

  String get _timeLabel {
    final period = reminder.hour < 12 ? 'AM' : 'PM';
    final hour12 = reminder.hour % 12 == 0 ? 12 : reminder.hour % 12;
    return '$hour12:${reminder.minute.toString().padLeft(2, '0')} $period';
  }

  String get _daysLabel {
    if (reminder.daysOfWeek.isEmpty) return 'Every day';
    return reminder.daysOfWeek.map((code) => _dayLabels[_dayCodes.indexOf(code)]).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ForgeCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_timeLabel, style: theme.textTheme.titleMedium),
                  Text(_daysLabel, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Switch(
              value: reminder.active,
              onChanged: (_) => ref.read(habitRemindersControllerProvider(habit.id).notifier).toggleActive(habit, reminder),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () =>
                  ref.read(habitRemindersControllerProvider(habit.id).notifier).deleteReminder(habit.id, reminder.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderEditorSheet extends ConsumerStatefulWidget {
  const _ReminderEditorSheet({required this.habit});

  final Habit habit;

  @override
  ConsumerState<_ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends ConsumerState<_ReminderEditorSheet> {
  TimeOfDay _time = TimeOfDay.now();
  final Set<int> _selectedDays = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Reminder', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded),
            title: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: 12),
          Text('Repeat on', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final selected = _selectedDays.contains(i);
              return FilterChip(
                label: Text(_dayLabels[i]),
                selected: selected,
                onSelected: (v) => setState(() => v ? _selectedDays.add(i) : _selectedDays.remove(i)),
              );
            }),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _selectedDays.isEmpty ? 'No days selected means every day.' : '',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const LoadingView(compact: true) : const Text('Save Reminder'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await NotificationService.instance.requestPermission();
    final draft = HabitReminderDraft(
      hour: _time.hour,
      minute: _time.minute,
      daysOfWeek: [for (final i in _selectedDays) _dayCodes[i]],
      active: true,
    );
    final failure = await ref.read(habitRemindersControllerProvider(widget.habit.id).notifier).addReminder(
          widget.habit,
          draft,
        );
    if (!mounted) return;
    if (failure != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    Navigator.of(context).pop();
  }
}
