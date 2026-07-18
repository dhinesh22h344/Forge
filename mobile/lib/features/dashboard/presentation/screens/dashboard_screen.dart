import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/forge_flame.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../../categories/presentation/screens/categories_list_screen.dart';
import '../../../habits/presentation/screens/create_habit_screen.dart';
import '../../../journal/presentation/screens/journal_list_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_widget_config.dart';
import '../../domain/entities/dashboard_widget_type.dart';
import '../providers/dashboard_controller.dart';
import '../widgets/dashboard_widget_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'Dashboard' : 'Hey, ${user.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Journal',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const JournalListScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Theme',
            onPressed: () => context.push('/settings/theme'),
          ),
          dashboardAsync.maybeWhen(
            data: (state) => IconButton(
              icon: Icon(
                state.isCustomizing ? Icons.check_rounded : Icons.tune_rounded,
              ),
              tooltip: state.isCustomizing ? 'Done' : 'Customize',
              onPressed: () => ref
                  .read(dashboardControllerProvider.notifier)
                  .toggleCustomizing(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load your dashboard'),
          onRetry: () => ref.invalidate(dashboardControllerProvider),
        ),
        data: (state) => state.isCustomizing
            ? _CustomizeList(layout: state.layout)
            : Column(
                children: [
                  _FlameHeader(summary: state.summary),
                  Expanded(
                    child: _WidgetList(
                      layout: state.visibleLayout,
                      summary: state.summary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The dashboard's signature surface — the Forge Flame reads consistency
/// across every category at once (see [DashboardSummary.consistencyScore]),
/// so it lives here rather than under any one widget in the customizable
/// list below it.
class _FlameHeader extends StatelessWidget {
  const _FlameHeader({required this.summary});
  final DashboardSummary summary;

  String get _caption {
    if (summary.todayTotal == 0 && summary.currentStreak == 0) {
      return 'Light your first habit today';
    }
    final pct = (summary.consistencyScore * 100).round();
    if (summary.currentStreak == 0) return '$pct% consistent today';
    return '$pct% consistent · ${summary.currentStreak}-day streak';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          ForgeFlame(intensity: summary.consistencyScore, size: 132),
          const SizedBox(height: 6),
          Text(_caption, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WidgetList extends ConsumerWidget {
  const _WidgetList({required this.layout, required this.summary});
  final List<DashboardWidgetConfig> layout;
  final DashboardSummary summary;

  Future<void> _openQuickAdd(BuildContext context, WidgetRef ref) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (layout.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'All widgets are hidden. Tap the tune icon to bring some back.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: layout.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final type = layout[i].type;
        return StaggeredFadeIn(
          index: i,
          child: DashboardWidgetCard(
            type: type,
            summary: summary,
            onTap: type == DashboardWidgetType.quickAdd
                ? () => _openQuickAdd(context, ref)
                : null,
          ),
        );
      },
    );
  }
}

class _CustomizeList extends ConsumerWidget {
  const _CustomizeList({required this.layout});
  final List<DashboardWidgetConfig> layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordered = List<DashboardWidgetConfig>.from(layout)
      ..sort((a, b) => a.position.compareTo(b.position));
    final controller = ref.read(dashboardControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Drag to reorder. Toggle to hide a widget from your dashboard.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ordered.length,
            onReorder: controller.reorder,
            itemBuilder: (context, i) {
              final config = ordered[i];
              return ForgeCard(
                key: ValueKey(config.type),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_handle_rounded),
                    const SizedBox(width: 12),
                    Expanded(child: Text(config.type.label)),
                    Switch(
                      value: config.isVisible,
                      onChanged: (_) => controller.toggleVisibility(config),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
