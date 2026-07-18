import '../../domain/entities/dashboard_widget_config.dart';
import '../../domain/entities/dashboard_widget_type.dart';

class DashboardWidgetConfigModel {
  static DashboardWidgetConfig fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      type: DashboardWidgetType.values.byName(json['widgetType'] as String),
      position: json['position'] as int,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toJson(DashboardWidgetConfig config) {
    return {
      'widgetType': config.type.name,
      'position': config.position,
      'isVisible': config.isVisible,
    };
  }
}
