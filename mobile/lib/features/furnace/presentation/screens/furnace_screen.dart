import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../providers/furnace_controller.dart';
import '../widgets/ember_card.dart';

/// The Furnace: non-punitive streak recovery. A missed scheduled day doesn't
/// break a streak the instant it's read — it lands here as a recoverable
/// "ember" until the grace window (through the end of the day after the
/// miss) closes.
class FurnaceScreen extends ConsumerWidget {
  const FurnaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final embersAsync = ref.watch(furnaceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('The Furnace')),
      body: embersAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load the furnace'),
          onRetry: () => ref.invalidate(furnaceControllerProvider),
        ),
        data: (embers) {
          if (embers.isEmpty) {
            return const EmptyState(
              icon: Icons.local_fire_department_outlined,
              title: 'Nothing in the furnace',
              message: 'Miss a scheduled day and it lands here — reforge it before the embers cool.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: embers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => StaggeredFadeIn(
              index: i,
              child: EmberCard(
                ember: embers[i],
                onReforge: () => _reforge(context, ref, embers[i].habitId),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _reforge(BuildContext context, WidgetRef ref, String habitId) async {
    final failure = await ref.read(furnaceControllerProvider.notifier).reforge(habitId);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reforged — streak restored.')),
    );
  }
}
