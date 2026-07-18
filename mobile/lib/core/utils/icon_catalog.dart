import 'package:flutter/material.dart';

/// Maps a stable string key (stored server-side) to a Material icon glyph.
/// Shared by categories and habits so both pickers offer the same set and a
/// key created in one screen always renders correctly in the other.
class IconCatalog {
  const IconCatalog._();

  static const Map<String, IconData> icons = {
    'dumbbell': Icons.fitness_center_rounded,
    'book': Icons.menu_book_rounded,
    'code': Icons.code_rounded,
    'money': Icons.attach_money_rounded,
    'briefcase': Icons.work_rounded,
    'game': Icons.sports_esports_rounded,
    'health': Icons.favorite_rounded,
    'meditation': Icons.self_improvement_rounded,
    'religion': Icons.church_rounded,
    'water': Icons.water_drop_rounded,
    'sleep': Icons.bedtime_rounded,
    'music': Icons.music_note_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'pets': Icons.pets_rounded,
    'people': Icons.people_rounded,
    'run': Icons.directions_run_rounded,
    'palette': Icons.palette_rounded,
    'school': Icons.school_rounded,
    'star': Icons.star_rounded,
    'target': Icons.track_changes_rounded,
    'cloud': Icons.cloud_rounded,
    'leaf': Icons.eco_rounded,
    'coffee': Icons.coffee_rounded,
    'camera': Icons.camera_alt_rounded,
    'home': Icons.home_rounded,
  };

  static IconData resolve(String? key) => icons[key] ?? Icons.category_rounded;
}
