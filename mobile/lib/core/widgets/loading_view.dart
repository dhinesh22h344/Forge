import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final indicator = const CircularProgressIndicator(strokeWidth: 2.5);
    if (compact) {
      return SizedBox(height: 24, width: 24, child: indicator);
    }
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: indicator));
  }
}
