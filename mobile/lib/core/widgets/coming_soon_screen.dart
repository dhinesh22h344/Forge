import 'package:flutter/material.dart';

/// Placeholder for bottom-nav tabs whose feature milestone hasn't shipped
/// yet (Habits → M5, Reports → M7, Profile → cross-cutting). Keeps the shell
/// navigable end-to-end now instead of leaving dead tabs, without faking a
/// feature that doesn't exist.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon, required this.milestone});

  final String title;
  final IconData icon;
  final String milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('$title lands in $milestone', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
