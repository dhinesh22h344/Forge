import 'package:flutter/material.dart';

/// Maps the icon keys the backend catalog sends (see
/// com.forge.achievement.catalog.AchievementCode) to Flutter glyphs. Every
/// key here is a real `Icons.*` identifier by convention, so this map is a
/// 1:1 lookup rather than a semantic translation.
class AchievementIcons {
  const AchievementIcons._();

  static const Map<String, IconData> _icons = {
    'flag_rounded': Icons.flag_rounded,
    'workspace_premium_rounded': Icons.workspace_premium_rounded,
    'local_fire_department_rounded': Icons.local_fire_department_rounded,
    'whatshot_rounded': Icons.whatshot_rounded,
    'bolt_rounded': Icons.bolt_rounded,
    'military_tech_rounded': Icons.military_tech_rounded,
    'grid_view_rounded': Icons.grid_view_rounded,
    'architecture_rounded': Icons.architecture_rounded,
    'diamond_rounded': Icons.diamond_rounded,
    'lock_rounded': Icons.lock_rounded,
  };

  static IconData resolve(String key) => _icons[key] ?? Icons.emoji_events_rounded;
}
