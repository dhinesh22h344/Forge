import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../domain/entities/journal_entry.dart';
import '../providers/journal_controller.dart';
import 'journal_entry_screen.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        tooltip: "Today's entry",
        onPressed: () => _openEntry(context, ref, DateTime.now()),
        child: const Icon(Icons.edit_rounded),
      ),
      body: entriesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          failure: const UnknownFailure('Could not load your journal'),
          onRetry: () => ref.invalidate(journalControllerProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'No entries yet',
              message: 'Write about today — one entry per day, edit it anytime.',
              actionLabel: "Write Today's Entry",
              onAction: () => _openEntry(context, ref, DateTime.now()),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final entry = entries[i];
              return StaggeredFadeIn(
                index: i,
                child: ForgeCard(
                  onTap: () => _openEntry(context, ref, entry.entryDate, existing: entry),
                  child: Row(
                    children: [
                      if (entry.mood != null) ...[
                        Text(entry.mood!.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMMd().format(entry.entryDate), style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              entry.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openEntry(BuildContext context, WidgetRef ref, DateTime date, {JournalEntry? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JournalEntryScreen(date: date, existing: existing)),
    );
  }
}
