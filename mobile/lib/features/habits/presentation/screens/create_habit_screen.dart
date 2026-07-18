import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/color_palette_picker.dart';
import '../../../../core/widgets/icon_picker.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/repeat_type.dart';
import '../../domain/repositories/habit_repository.dart';
import '../providers/habits_controller.dart';

const _weekdayAbbrevs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key, this.editing});

  final Habit? editing;

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.editing?.name);
  late final _descriptionController = TextEditingController(text: widget.editing?.description);
  late final _emojiController = TextEditingController(text: widget.editing?.emoji);
  late final _goalValueController = TextEditingController(text: widget.editing?.goalValue?.toString());
  late final _goalUnitController = TextEditingController(text: widget.editing?.goalUnit);
  late final _estimatedTimeController =
      TextEditingController(text: widget.editing?.estimatedTimeMinutes?.toString());
  late final _notesController = TextEditingController(text: widget.editing?.notes);
  late final _folderController = TextEditingController(text: widget.editing?.folder);
  late final _tagsController = TextEditingController();
  late final _dayOfMonthController =
      TextEditingController(text: widget.editing?.repeatConfig['dayOfMonth']?.toString() ?? '1');

  String? _categoryId;
  String _icon = 'star';
  int _priority = 2;
  int _difficulty = 3;
  late RepeatType _repeatType = widget.editing?.repeatType ?? RepeatType.daily;
  late final Set<String> _specificDays =
      (widget.editing?.repeatConfig['days'] as List?)?.cast<String>().toSet() ?? {'MON', 'WED', 'FRI'};
  int _yearlyMonth = 1;
  int _yearlyDay = 1;
  late String _color = widget.editing?.color ?? forgePalette.first;
  bool _useGradient = false;
  late String _gradientEnd = forgePalette[1];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<String> _tags = [];
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.editing?.categoryId;
    _icon = widget.editing?.icon ?? 'star';
    _priority = widget.editing?.priority ?? 2;
    _difficulty = widget.editing?.difficulty ?? 3;
    _startDate = widget.editing?.startDate ?? DateTime.now();
    _endDate = widget.editing?.endDate;
    _tags.addAll(widget.editing?.tags ?? const []);
    final month = widget.editing?.repeatConfig['month'];
    final day = widget.editing?.repeatConfig['day'];
    if (month != null) _yearlyMonth = int.parse('$month');
    if (day != null) _yearlyDay = int.parse('$day');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emojiController.dispose();
    _goalValueController.dispose();
    _goalUnitController.dispose();
    _estimatedTimeController.dispose();
    _notesController.dispose();
    _folderController.dispose();
    _tagsController.dispose();
    _dayOfMonthController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _repeatConfig {
    switch (_repeatType) {
      case RepeatType.specificDays:
        return {'days': _specificDays.toList()};
      case RepeatType.monthly:
        return {'dayOfMonth': int.tryParse(_dayOfMonthController.text) ?? 1};
      case RepeatType.yearly:
        return {'month': _yearlyMonth, 'day': _yearlyDay};
      case RepeatType.daily:
      case RepeatType.weekdays:
      case RepeatType.weekends:
      case RepeatType.custom:
        return {};
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagsController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      setState(() => _errorMessage = 'Choose a category');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final draft = HabitDraft(
      categoryId: _categoryId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      icon: _icon,
      emoji: _emojiController.text.trim().isEmpty ? null : _emojiController.text.trim(),
      priority: _priority,
      difficulty: _difficulty,
      repeatType: _repeatType,
      repeatConfig: _repeatConfig,
      goalValue: double.tryParse(_goalValueController.text),
      goalUnit: _goalUnitController.text.trim().isEmpty ? null : _goalUnitController.text.trim(),
      estimatedTimeMinutes: int.tryParse(_estimatedTimeController.text),
      color: _color,
      gradient: _useGradient ? '$_color,$_gradientEnd' : null,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      tags: _tags,
      folder: _folderController.text.trim().isEmpty ? null : _folderController.text.trim(),
    );

    final controller = ref.read(habitsControllerProvider.notifier);
    final failure =
        _isEditing ? await controller.updateHabit(widget.editing!.id, draft) : await controller.createHabit(draft);

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
    final categories = ref.watch(categoriesControllerProvider).value ?? const [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Habit' : 'New Habit')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emojiController,
                  decoration: const InputDecoration(labelText: 'Emoji (optional)'),
                  maxLength: 2,
                ),
                const SizedBox(height: 16),
                Text('Icon', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                IconPicker(selected: _icon, accentColor: _parseColor(_color), onChanged: (i) => setState(() => _icon = i)),
                const SizedBox(height: 24),

                Text('Priority', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Low')),
                    ButtonSegment(value: 2, label: Text('Medium')),
                    ButtonSegment(value: 3, label: Text('High')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (v) => setState(() => _priority = v.first),
                ),
                const SizedBox(height: 24),

                Text('Difficulty', style: theme.textTheme.titleMedium),
                Slider(
                  value: _difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$_difficulty',
                  onChanged: (v) => setState(() => _difficulty = v.round()),
                ),
                const SizedBox(height: 16),

                Text('Repeat', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<RepeatType>(
                  initialValue: _repeatType,
                  items: [for (final r in RepeatType.values) DropdownMenuItem(value: r, child: Text(r.label))],
                  onChanged: (v) => setState(() => _repeatType = v ?? RepeatType.daily),
                ),
                if (_repeatType == RepeatType.specificDays) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final day in _weekdayAbbrevs)
                        FilterChip(
                          label: Text(day),
                          selected: _specificDays.contains(day),
                          onSelected: (selected) => setState(
                              () => selected ? _specificDays.add(day) : _specificDays.remove(day)),
                        ),
                    ],
                  ),
                ],
                if (_repeatType == RepeatType.monthly) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dayOfMonthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Day of month (1-31)'),
                  ),
                ],
                if (_repeatType == RepeatType.yearly) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _yearlyMonth,
                          decoration: const InputDecoration(labelText: 'Month'),
                          items: [for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text('$m'))],
                          onChanged: (v) => setState(() => _yearlyMonth = v ?? 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _yearlyDay,
                          decoration: const InputDecoration(labelText: 'Day'),
                          items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
                          onChanged: (v) => setState(() => _yearlyDay = v ?? 1),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _goalValueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Goal (optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _goalUnitController,
                        decoration: const InputDecoration(labelText: 'Unit (e.g. pages)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _estimatedTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Estimated time (minutes, optional)'),
                ),
                const SizedBox(height: 24),

                Text('Color', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ColorPalettePicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use gradient'),
                  value: _useGradient,
                  onChanged: (v) => setState(() => _useGradient = v),
                ),
                if (_useGradient) ColorPalettePicker(selected: _gradientEnd, onChanged: (c) => setState(() => _gradientEnd = c)),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text('Start: ${_formatDate(_startDate)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(_endDate == null ? 'End date' : _formatDate(_endDate!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folderController,
                  decoration: const InputDecoration(labelText: 'Folder (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(labelText: 'Add a tag and press enter'),
                  onSubmitted: _addTag,
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final tag in _tags)
                        Chip(label: Text(tag), onDeleted: () => setState(() => _tags.remove(tag))),
                    ],
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Save Changes' : 'Create Habit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Color _parseColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}
