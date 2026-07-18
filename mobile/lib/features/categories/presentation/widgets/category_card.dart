import 'package:flutter/material.dart';

import '../../../../core/utils/icon_catalog.dart';
import '../../domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap, this.subtitle});

  final Category category;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseColor(category.color);
    final gradientColors = _parseGradient(category.gradient) ?? [baseColor, baseColor.withValues(alpha: 0.7)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconCatalog.resolve(category.icon), color: Colors.white, size: 28),
              const SizedBox(height: 16),
              Text(
                category.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  List<Color>? _parseGradient(String? gradient) {
    if (gradient == null || !gradient.contains(',')) return null;
    final parts = gradient.split(',');
    if (parts.length != 2) return null;
    return [_parseColor(parts[0]), _parseColor(parts[1])];
  }
}
