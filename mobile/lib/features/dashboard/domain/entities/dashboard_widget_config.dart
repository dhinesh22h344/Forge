import 'dashboard_widget_type.dart';

class DashboardWidgetConfig {
  const DashboardWidgetConfig({
    required this.type,
    required this.position,
    required this.isVisible,
  });

  final DashboardWidgetType type;
  final int position;
  final bool isVisible;

  DashboardWidgetConfig copyWith({int? position, bool? isVisible}) {
    return DashboardWidgetConfig(
      type: type,
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Sensible first-run layout — every widget visible, in the order they
  /// read most naturally on a fresh (empty) dashboard. Persisted to the
  /// backend the first time the user reorders/hides anything.
  static List<DashboardWidgetConfig> defaultLayout() {
    return DashboardWidgetType.values
        .asMap()
        .entries
        .map((e) => DashboardWidgetConfig(type: e.value, position: e.key, isVisible: true))
        .toList();
  }
}
