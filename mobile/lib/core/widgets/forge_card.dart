import 'package:flutter/material.dart';

/// The base surface for every dashboard widget/card in the app — rounded,
/// bordered, no heavy elevation shadow (matches the flat premium look of
/// Linear/Notion rather than Material's default drop-shadow cards).
class ForgeCard extends StatelessWidget {
  const ForgeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
          ),
          child: child,
        ),
      ),
    );
  }
}
