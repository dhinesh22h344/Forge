import 'package:flutter/material.dart';

/// Curated hex palette shared by category/habit creation — a full color-wheel
/// picker would need a new package dependency for a premium app that's
/// better served by a tasteful preset palette anyway (matches the "gradient
/// swatches" pattern in Notion/Linear rather than a raw color wheel).
const List<String> forgePalette = [
  '#6C5CE7',
  '#00D9C0',
  '#FF6B6B',
  '#FFA94D',
  '#FFD43B',
  '#69DB7C',
  '#38D9A9',
  '#4DABF7',
  '#748FFC',
  '#DA77F2',
  '#F783AC',
  '#868E96',
];

class ColorPalettePicker extends StatelessWidget {
  const ColorPalettePicker({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final hex in forgePalette)
          GestureDetector(
            onTap: () => onChanged(hex),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(hex),
                shape: BoxShape.circle,
                border: hex == selected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: hex == selected
                    ? [BoxShadow(color: _parseColor(hex).withValues(alpha: 0.6), blurRadius: 8)]
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Color _parseColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}
