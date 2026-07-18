import 'package:flutter/material.dart';

/// The base surface for every dashboard widget/card in the app — rounded,
/// bordered, no heavy elevation shadow (matches the flat premium look of
/// Linear/Notion rather than Material's default drop-shadow cards).
///
/// Every tappable card in the app is built on this one widget, so the
/// press-scale feedback here is what gives the whole app a consistent
/// "tactile" feel from a single change point — no per-screen wiring needed.
class ForgeCard extends StatefulWidget {
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
  State<ForgeCard> createState() => _ForgeCardState();
}

class _ForgeCardState extends State<ForgeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
