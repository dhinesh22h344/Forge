import 'package:home_widget/home_widget.dart';

import '../../features/dashboard/domain/entities/dashboard_summary.dart';

/// Mirrors today's completion count and current streak into the platform's
/// shared widget storage, then asks the native side to redraw. Called from
/// [DashboardController] every time the summary is (re)loaded — that
/// provider is already invalidated on every habit toggle (see
/// HabitsController.toggleToday), so this stays in sync without a second
/// call site.
class HomeWidgetSync {
  const HomeWidgetSync._();

  static const String androidProviderName = 'ForgeWidgetProvider';
  static const String iOSWidgetName = 'ForgeWidget';

  /// Must match the App Group configured on both the Runner and ForgeWidget
  /// extension targets in Xcode (Signing & Capabilities -> App Groups) —
  /// see ios/README_WIDGET_SETUP.md. Android ignores this; `setAppGroupId`
  /// is a no-op there.
  static const String iOSAppGroupId = 'group.com.forge.forge.widget';

  static Future<void> sync(DashboardSummary summary) async {
    await HomeWidget.saveWidgetData<int>('todayCompleted', summary.todayCompleted);
    await HomeWidget.saveWidgetData<int>('todayTotal', summary.todayTotal);
    await HomeWidget.saveWidgetData<int>('currentStreak', summary.currentStreak);
    await HomeWidget.updateWidget(androidName: androidProviderName, iOSName: iOSWidgetName);
  }
}
