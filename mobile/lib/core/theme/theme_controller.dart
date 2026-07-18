import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'app_theme.dart';
import 'forge_palette.dart';

class ThemeState {
  const ThemeState({required this.themeId, this.customAccent});

  final ForgeThemeId themeId;
  final Color? customAccent;

  ForgePalette get palette {
    final base = ForgePalettes.byId(themeId);
    return customAccent == null ? base : base.withAccent(customAccent!);
  }
}

/// Persists the user's chosen theme (and optional custom accent) to secure
/// storage. [build] returns Dark synchronously so [MaterialApp] always has a
/// [ThemeData] for the first frame — the persisted choice, if any, replaces
/// it as soon as storage has been read.
class ThemeController extends Notifier<ThemeState> {
  static const _themeKey = 'forge_theme_id';
  static const _accentKey = 'forge_theme_accent';

  @override
  ThemeState build() {
    _restore();
    return const ThemeState(themeId: ForgeThemeId.dark);
  }

  Future<void> _restore() async {
    final storage = ref.read(secureStorageProvider);
    final storedId = await storage.read(key: _themeKey);
    final storedAccent = await storage.read(key: _accentKey);

    var themeId = ForgeThemeId.dark;
    for (final candidate in ForgeThemeId.values) {
      if (candidate.name == storedId) {
        themeId = candidate;
        break;
      }
    }
    final accent = storedAccent == null ? null : Color(int.parse(storedAccent, radix: 16));

    state = ThemeState(themeId: themeId, customAccent: accent);
  }

  Future<void> setTheme(ForgeThemeId themeId) async {
    state = ThemeState(themeId: themeId, customAccent: state.customAccent);
    await ref.read(secureStorageProvider).write(key: _themeKey, value: themeId.name);
  }

  Future<void> setCustomAccent(Color? accent) async {
    state = ThemeState(themeId: state.themeId, customAccent: accent);
    final storage = ref.read(secureStorageProvider);
    if (accent == null) {
      await storage.delete(key: _accentKey);
    } else {
      await storage.write(key: _accentKey, value: accent.toARGB32().toRadixString(16));
    }
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

final themeDataProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeControllerProvider);
  return AppTheme.build(state.palette);
});
