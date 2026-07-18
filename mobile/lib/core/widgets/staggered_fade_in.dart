import 'package:flutter/material.dart';

/// Fades + slides a single list/grid item in on first build, delayed by
/// [index] so a screenful of cards arrives as one staggered wave instead of
/// popping in all at once. Purely an entrance effect — wrap each item at the
/// builder callsite, not the list itself.
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 35),
    this.maxDelay = const Duration(milliseconds: 350),
  });

  final int index;
  final Widget child;
  final Duration step;
  final Duration maxDelay;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curved;
    _slide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curved);

    final delay = widget.step * widget.index;
    Future.delayed(delay > widget.maxDelay ? widget.maxDelay : delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
