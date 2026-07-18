import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../data/local/seen_achievements_store.dart';
import '../../domain/entities/achievement.dart';
import '../providers/achievements_controller.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_icons.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  bool _announcing = false;

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsControllerProvider);

    ref.listen(achievementsControllerProvider, (previous, next) {
      final achievements = next.value;
      if (achievements != null) _maybeAnnounceUnlocks(achievements);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: achievementsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load achievements'),
          onRetry: () => ref.invalidate(achievementsControllerProvider),
        ),
        data: (achievements) => GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, i) => AchievementCard(achievement: achievements[i]),
        ),
      ),
    );
  }

  /// Diffs the fetched list against the locally-persisted "seen" set and
  /// plays the unlock animation for anything newly earned. On a user's very
  /// first visit to this screen, everything already unlocked counts as
  /// "new" — a celebratory recap rather than a bug, and it avoids needing a
  /// separate baseline-seeding step.
  Future<void> _maybeAnnounceUnlocks(List<Achievement> achievements) async {
    if (_announcing) return;
    final store = ref.read(seenAchievementsStoreProvider);
    final seen = await store.read();
    final newlyUnlocked = achievements.where((a) => a.unlocked && !seen.contains(a.code)).toList();
    if (newlyUnlocked.isEmpty) return;

    _announcing = true;
    await store.markSeen({for (final a in newlyUnlocked) a.code});
    for (final achievement in newlyUnlocked) {
      if (!mounted) break;
      await _showUnlockDialog(achievement);
    }
    _announcing = false;
  }

  Future<void> _showUnlockDialog(Achievement achievement) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement unlocked',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, _, __) => _UnlockDialog(achievement: achievement),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

class _UnlockDialog extends StatelessWidget {
  const _UnlockDialog({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                  ),
                  child: Icon(AchievementIcons.resolve(achievement.icon), size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(achievement.title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(achievement.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
