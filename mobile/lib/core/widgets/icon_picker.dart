import 'package:flutter/material.dart';

import '../utils/icon_catalog.dart';

class IconPicker extends StatelessWidget {
  const IconPicker({super.key, required this.selected, required this.onChanged, required this.accentColor});

  final String? selected;
  final ValueChanged<String> onChanged;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in IconCatalog.icons.entries)
          GestureDetector(
            onTap: () => onChanged(entry.key),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: entry.key == selected ? accentColor : theme.colorScheme.surface,
                border: Border.all(color: entry.key == selected ? accentColor : theme.dividerTheme.color!),
              ),
              child: Icon(
                entry.value,
                color: entry.key == selected ? Colors.white : theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}
