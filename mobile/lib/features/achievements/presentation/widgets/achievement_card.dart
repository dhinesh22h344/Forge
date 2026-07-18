import 'package:flutter/material.dart';

import '../../../../core/widgets/forge_card.dart';
import '../../domain/entities/achievement.dart';
import 'achievement_icons.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locked = !achievement.unlocked;

    return ForgeCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked ? theme.colorScheme.onSurface.withValues(alpha: 0.08) : theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              AchievementIcons.resolve(achievement.icon),
              size: 28,
              color: locked ? theme.colorScheme.onSurface.withValues(alpha: 0.35) : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: locked ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
