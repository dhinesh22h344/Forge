import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/icon_catalog.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../domain/entities/furnace_ember.dart';

/// Warm, fixed fire-toned card — deliberately independent of the active
/// theme palette (see ForgePalette) since "an ember cooling" is a fire
/// metaphor that should read the same in every theme, the same way a
/// habit's own arbitrary color already does.
class EmberCard extends StatelessWidget {
  const EmberCard({super.key, required this.ember, required this.onReforge});

  final FurnaceEmber ember;
  final VoidCallback? onReforge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isDeadlineToday = ember.graceDeadline.year == today.year &&
        ember.graceDeadline.month == today.month &&
        ember.graceDeadline.day == today.day;
    final graceLabel = isDeadlineToday ? 'until end of today' : 'until end of tomorrow';

    return ForgeCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFF7A45), Color(0xFFFFC069)]),
            ),
            child: ember.habitEmoji != null
                ? Text(ember.habitEmoji!, style: const TextStyle(fontSize: 20))
                : Icon(IconCatalog.resolve(ember.habitIcon), color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ember.habitName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Missed ${DateFormat.MMMd().format(ember.missedDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 2),
                Text(
                  ember.recoverable ? 'Reforge $graceLabel or the streak breaks' : _cooldownLabel(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ember.recoverable ? const Color(0xFFFF7A45) : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ember.recoverable ? const Color(0xFFFF7A45) : null),
            onPressed: ember.recoverable ? onReforge : null,
            child: const Text('Reforge'),
          ),
        ],
      ),
    );
  }

  String _cooldownLabel() {
    final endsAt = ember.cooldownEndsAt;
    if (endsAt == null) return 'Already used this month';
    return 'Next reforge available ${DateFormat.MMMd().format(endsAt)}';
  }
}
