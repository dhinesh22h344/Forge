import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/forge_flame.dart';
import '../../data/local/seen_milestones_store.dart';
import '../providers/habit_detail_providers.dart';

/// Streak lengths that get a full-screen celebration. Kept as a plain const
/// list rather than deriving from the AchievementCode catalog — this fires
/// immediately at the moment of completion (see call sites in HabitCard and
/// HabitDetailScreen), independent of the Achievements tab's own diff-on-open
/// unlock animation.
const List<int> milestoneStreakDays = [7, 30, 100, 365];

/// Call right after a habit completion succeeds. Fetches the fresh streak,
/// and if it just landed on 7/30/100/365 and hasn't been celebrated before
/// for this habit, shows the celebration overlay.
Future<void> maybeCelebrateMilestone(
  BuildContext context,
  WidgetRef ref, {
  required String habitId,
  required String habitName,
}) async {
  ref.invalidate(habitStreakProvider(habitId));
  final streak = await ref.read(habitStreakProvider(habitId).future);
  if (!milestoneStreakDays.contains(streak.currentStreak)) return;

  final store = ref.read(seenMilestonesStoreProvider);
  final key = '$habitId:${streak.currentStreak}';
  final seen = await store.read();
  if (seen.contains(key)) return;

  await store.markSeen(key);
  if (!context.mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Milestone reached',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, _, __) => MilestoneCelebrationOverlay(days: streak.currentStreak, habitName: habitName),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
      return ScaleTransition(scale: curved, child: FadeTransition(opacity: animation, child: child));
    },
  );
}

String _titleFor(int days) => switch (days) {
      7 => 'One Week Strong',
      30 => 'One Month Strong',
      100 => 'Century',
      365 => 'One Full Year',
      _ => '$days Days',
    };

/// Uses [ForgeFlame] at full blaze — the app's signature identity mark,
/// otherwise reserved for the dashboard's overall consistency score (see
/// DashboardSummary.consistencyScore) — rather than a one-off icon, so a
/// milestone reads as "the flame is roaring" instead of introducing a
/// second, competing fire visual.
class MilestoneCelebrationOverlay extends StatelessWidget {
  const MilestoneCelebrationOverlay({super.key, required this.days, required this.habitName});

  final int days;
  final String habitName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ForgeFlame(intensity: 1.0, size: 100),
                const SizedBox(height: 8),
                Text(
                  '$days-DAY STREAK',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(_titleFor(days), style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(habitName, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
