import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_service.dart';
import 'core/offline/offline_sync_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: ForgeApp()));
}

class ForgeApp extends ConsumerStatefulWidget {
  const ForgeApp({super.key});

  @override
  ConsumerState<ForgeApp> createState() => _ForgeAppState();
}

class _ForgeAppState extends ConsumerState<ForgeApp> {
  @override
  void initState() {
    super.initState();
    // A reminder notification only carries a habit id — once it's tapped
    // (cold start or foreground), push straight to that habit's detail
    // screen. GoRouter instances can navigate without a BuildContext, so this
    // works even before any screen has built.
    NotificationService.instance.pendingHabitId.addListener(_handlePendingNotification);
    // Provider bodies are lazy — reading it here is what actually starts the
    // connectivity listener and flushes anything queued from a session that
    // ended while still offline.
    ref.read(offlineSyncServiceProvider);
  }

  void _handlePendingNotification() {
    final habitId = NotificationService.instance.pendingHabitId.value;
    if (habitId == null) return;
    NotificationService.instance.pendingHabitId.value = null;
    ref.read(routerProvider).push('/habits/$habitId');
  }

  @override
  void dispose() {
    NotificationService.instance.pendingHabitId.removeListener(_handlePendingNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeData = ref.watch(themeDataProvider);

    return MaterialApp.router(
      title: 'Forge',
      debugShowCheckedModeBanner: false,
      // Explicit theme selection (Dark/Light/AMOLED/Glass/Ocean/Forest/
      // Purple/Minimal/Cyberpunk/Neon + custom accent) via ThemeController,
      // not system brightness — see /settings/theme.
      theme: themeData,
      routerConfig: router,
    );
  }
}
