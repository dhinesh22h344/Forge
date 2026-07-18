import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/icon_catalog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../../categories/presentation/screens/create_category_screen.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/presentation/providers/habits_controller.dart';
import '../../../habits/presentation/screens/habit_detail_screen.dart';

/// Client-side search over habits and categories already held in memory by
/// [habitsControllerProvider]/[categoriesControllerProvider] — no dedicated
/// backend endpoint, since a personal habit tracker's data set is small
/// enough that fetching it once and filtering locally is simpler and faster
/// than a server round trip per keystroke.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsControllerProvider).value?.habits ?? const <Habit>[];
    final categories = ref.watch(categoriesControllerProvider).value ?? const <Category>[];

    final query = _query.trim().toLowerCase();
    final matchedCategories = query.isEmpty
        ? const <Category>[]
        : categories.where((c) => _matches(query, [c.name, c.description])).toList();
    final matchedHabits = query.isEmpty
        ? const <Habit>[]
        : habits.where((h) => _matches(query, [h.name, h.description])).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search habits and categories',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() {
                _controller.clear();
                _query = '';
              }),
            ),
        ],
      ),
      body: _buildBody(context, query, matchedCategories, matchedHabits),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String query,
    List<Category> matchedCategories,
    List<Habit> matchedHabits,
  ) {
    if (query.isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Search Forge',
        message: 'Find a habit or category by name.',
      );
    }
    if (matchedCategories.isEmpty && matchedHabits.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        message: 'Nothing matches "$query".',
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (matchedCategories.isNotEmpty) ...[
          const _SectionHeader('Categories'),
          for (final category in matchedCategories)
            ListTile(
              leading: Icon(IconCatalog.resolve(category.icon)),
              title: Text(category.name),
              subtitle: category.description == null ? null : Text(category.description!),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CreateCategoryScreen(editing: category)),
              ),
            ),
        ],
        if (matchedHabits.isNotEmpty) ...[
          const _SectionHeader('Habits'),
          for (final habit in matchedHabits)
            ListTile(
              leading: const Icon(Icons.checklist_rounded),
              title: Text(habit.name),
              subtitle: habit.description == null ? null : Text(habit.description!),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
              ),
            ),
        ],
      ],
    );
  }

  bool _matches(String query, List<String?> fields) {
    return fields.any((field) => field != null && field.toLowerCase().contains(query));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
