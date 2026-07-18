import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../../categories/presentation/screens/categories_list_screen.dart';
import '../../../furnace/presentation/providers/furnace_controller.dart';
import '../../../furnace/presentation/screens/furnace_screen.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../providers/habits_controller.dart';
import '../widgets/habit_card.dart';
import '../widgets/milestone_celebration.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsListScreen extends ConsumerWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    final categoriesAsync = ref.watch(categoriesControllerProvider);
    final embers = ref.watch(furnaceControllerProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesListScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createHabit(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: habitsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load habits'),
          onRetry: () => ref.invalidate(habitsControllerProvider),
        ),
        data: (state) {
          if (state.habits.isEmpty) {
            return EmptyState(
              icon: Icons.checklist_rounded,
              title: 'No habits yet',
              message:
                  'Create a habit inside one of your categories to start tracking.',
              actionLabel: 'Create Habit',
              onAction: () => _createHabit(context, ref),
            );
          }

          final categories = categoriesAsync.value ?? const [];
          final categoryNames = {for (final c in categories) c.id: c.name};
          final grouped = <String, List<Habit>>{};
          for (final habit in state.habits) {
            grouped.putIfAbsent(habit.categoryId, () => []).add(habit);
          }

          var cardIndex = 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (embers.isNotEmpty) ...[
                _FurnaceBanner(emberCount: embers.length),
                const SizedBox(height: 16),
              ],
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                  child: Text(
                    categoryNames[entry.key] ?? 'Uncategorized',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final habit in entry.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StaggeredFadeIn(
                      index: cardIndex++,
                      child: HabitCard(
                        habit: habit,
                        todayStatus: state.todayStatusByHabitId[habit.id],
                        onToggleToday: () async {
                          final wasCompleted = state.todayStatusByHabitId[habit.id] == HabitLogStatus.completed;
                          final failure = await ref.read(habitsControllerProvider.notifier).toggleToday(habit.id);
                          if (failure == null && !wasCompleted && context.mounted) {
                            await maybeCelebrateMilestone(context, ref, habitId: habit.id, habitName: habit.name);
                          }
                        },
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HabitDetailScreen(habit: habit),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _createHabit(BuildContext context, WidgetRef ref) async {
    final categories = ref.read(categoriesControllerProvider).value ?? const [];
    if (categories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a category first')));
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CategoriesListScreen()));
      return;
    }
    if (context.mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CreateHabitScreen()));
    }
  }
}

/// Surfaces The Furnace at the moment it's actually relevant — a missed day
/// still in its grace window — rather than leaving non-punitive recovery
/// buried behind the Achievements tab.
class _FurnaceBanner extends StatelessWidget {
  const _FurnaceBanner({required this.emberCount});

  final int emberCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForgeCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FurnaceScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFF7A45), Color(0xFFFFC069)]),
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emberCount == 1 ? '1 habit needs reforging' : '$emberCount habits need reforging',
                  style: theme.textTheme.titleSmall,
                ),
                Text('Recover it before the embers cool — tap to open The Furnace', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
