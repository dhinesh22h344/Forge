import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: ForgeApp()));
}

class ForgeApp extends ConsumerWidget {
  const ForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
