import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/dashboard_widget_config.dart';

class DashboardState {
  const DashboardState({
    required this.summary,
    required this.layout,
    this.isCustomizing = false,
  });

  final DashboardSummary summary;
  final List<DashboardWidgetConfig> layout;
  final bool isCustomizing;

  List<DashboardWidgetConfig> get visibleLayout =>
      layout.where((c) => c.isVisible).toList()..sort((a, b) => a.position.compareTo(b.position));

  DashboardState copyWith({DashboardSummary? summary, List<DashboardWidgetConfig>? layout, bool? isCustomizing}) {
    return DashboardState(
      summary: summary ?? this.summary,
      layout: layout ?? this.layout,
      isCustomizing: isCustomizing ?? this.isCustomizing,
    );
  }
}

class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final repository = ref.watch(dashboardRepositoryProvider);
    final summaryResult = await repository.getSummary();
    final layoutResult = await repository.getWidgetLayout();

    final summary = summaryResult.when(success: (s) => s, failure: (_) => DashboardSummary.empty);
    final layout = layoutResult.when(success: (l) => l, failure: (_) => DashboardWidgetConfig.defaultLayout());

    return DashboardState(summary: summary, layout: layout);
  }

  void toggleCustomizing() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isCustomizing: !current.isCustomizing));
  }

  Future<void> toggleVisibility(DashboardWidgetConfig target) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.layout
        .map((c) => c.type == target.type ? c.copyWith(isVisible: !c.isVisible) : c)
        .toList();
    state = AsyncData(current.copyWith(layout: updated));
    await ref.read(dashboardRepositoryProvider).saveWidgetLayout(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) return;

    final ordered = List<DashboardWidgetConfig>.from(current.layout)
      ..sort((a, b) => a.position.compareTo(b.position));

    if (newIndex > oldIndex) newIndex -= 1;
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);

    final repositioned = [
      for (var i = 0; i < ordered.length; i++) ordered[i].copyWith(position: i),
    ];

    state = AsyncData(current.copyWith(layout: repositioned));
    await ref.read(dashboardRepositoryProvider).saveWidgetLayout(repositioned);
  }
}

final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);
