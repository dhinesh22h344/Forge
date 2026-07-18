import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../../categories/presentation/screens/categories_list_screen.dart';
import '../../domain/entities/habit.dart';
import '../providers/habits_controller.dart';
import '../widgets/habit_card.dart';
import 'create_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsListScreen extends ConsumerWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    final categoriesAsync = ref.watch(categoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesListScreen())),
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
              message: 'Create a habit inside one of your categories to start tracking.',
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                    child: HabitCard(
                      habit: habit,
                      todayStatus: state.todayStatusByHabitId[habit.id],
                      onToggleToday: () => ref.read(habitsControllerProvider.notifier).toggleToday(habit.id),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit))),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a category first')),
      );
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesListScreen()));
      return;
    }
    if (context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateHabitScreen()));
    }
  }
}
