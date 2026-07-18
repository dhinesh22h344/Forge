import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/color_palette_picker.dart';
import '../../../../core/widgets/icon_picker.dart';
import '../../domain/entities/category.dart';
import '../providers/categories_controller.dart';

class CreateCategoryScreen extends ConsumerStatefulWidget {
  const CreateCategoryScreen({super.key, this.editing});

  final Category? editing;

  @override
  ConsumerState<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends ConsumerState<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.editing?.name);
  late final _descriptionController = TextEditingController(text: widget.editing?.description);
  late String _color = widget.editing?.color ?? forgePalette.first;
  bool _useGradient = false;
  late String _gradientEnd = forgePalette[1];
  bool _isSaving = false;
  String? _errorMessage;
  late String _icon = widget.editing?.icon ?? 'star';

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final gradient = _useGradient ? '$_color,$_gradientEnd' : null;
    final controller = ref.read(categoriesControllerProvider.notifier);
    final failure = _isEditing
        ? await controller.updateCategory(
            id: widget.editing!.id,
            name: _nameController.text.trim(),
            color: _color,
            gradient: gradient,
            icon: _icon,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          )
        : await controller.create(
            name: _nameController.text.trim(),
            color: _color,
            gradient: gradient,
            icon: _icon,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          );

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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Category' : 'New Category')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 24),
                Text('Color', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ColorPalettePicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use gradient'),
                  value: _useGradient,
                  onChanged: (v) => setState(() => _useGradient = v),
                ),
                if (_useGradient) ...[
                  const SizedBox(height: 8),
                  Text('Gradient end color', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ColorPalettePicker(selected: _gradientEnd, onChanged: (c) => setState(() => _gradientEnd = c)),
                ],
                const SizedBox(height: 24),
                Text('Icon', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                IconPicker(
                  selected: _icon,
                  accentColor: _parseColor(_color),
                  onChanged: (i) => setState(() => _icon = i),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Save Changes' : 'Create Category'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}
