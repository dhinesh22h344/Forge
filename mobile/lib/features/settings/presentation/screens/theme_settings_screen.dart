import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/forge_palette.dart';
import '../../../../core/theme/theme_controller.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  static const _accentOptions = [
    Color(0xFF6C5CE7),
    Color(0xFF00D9C0),
    Color(0xFF0EA5E9),
    Color(0xFF4CAF6D),
    Color(0xFFF15BB5),
    Color(0xFFFF2079),
    Color(0xFF39FF14),
    Color(0xFFFBBF24),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ForgePalettes.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, i) {
              final palette = ForgePalettes.all[i];
              final selected = palette.id == themeState.themeId;
              return _ThemeSwatch(
                palette: palette,
                selected: selected,
                onTap: () => controller.setTheme(palette.id),
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Custom accent', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Overrides the accent color on top of your chosen theme.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AccentSwatch(
                color: null,
                selected: themeState.customAccent == null,
                onTap: () => controller.setCustomAccent(null),
              ),
              for (final color in _accentOptions)
                _AccentSwatch(
                  color: color,
                  selected: themeState.customAccent?.toARGB32() == color.toARGB32(),
                  onTap: () => controller.setCustomAccent(color),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.palette, required this.selected, required this.onTap});

  final ForgePalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? palette.primary : palette.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: palette.primaryGradient),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                palette.id.label,
                style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: palette.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({required this.color, required this.selected, required this.onTap});

  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? theme.colorScheme.surface,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: selected ? 3 : 1,
          ),
        ),
        child: color == null ? Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.onSurface) : null,
      ),
    );
  }
}
