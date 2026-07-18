import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/journal_entry.dart';
import '../providers/journal_controller.dart';

/// View/edit the single journal entry for [date] — one entry per calendar
/// day (upsert semantics), so this screen doubles as both "write today's
/// entry" and "edit a past one" depending on whether [existing] is null.
class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, required this.date, this.existing});

  final DateTime date;
  final JournalEntry? existing;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late final _contentController = TextEditingController(text: widget.existing?.content);
  late JournalMood? _mood = widget.existing?.mood;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      setState(() => _errorMessage = 'Write something first');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final failure = await ref
        .read(journalControllerProvider.notifier)
        .upsert(date: widget.date, content: content, mood: _mood);

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (failure != null) {
      setState(() => _errorMessage = failure.message);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    setState(() => _isSaving = true);
    final failure = await ref.read(journalControllerProvider.notifier).delete(widget.date);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (failure != null) {
      setState(() => _errorMessage = failure.message);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMMd().format(widget.date)),
        actions: [
          if (widget.existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete entry',
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mood', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final mood in JournalMood.values)
                    ChoiceChip(
                      label: Text('${mood.emoji} ${mood.label}'),
                      selected: _mood == mood,
                      onSelected: (selected) => setState(() => _mood = selected ? mood : null),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _contentController,
                maxLines: 10,
                minLines: 6,
                decoration: const InputDecoration(
                  labelText: 'What happened today?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
