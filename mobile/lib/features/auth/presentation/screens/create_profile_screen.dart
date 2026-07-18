import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';

const _languages = {'en': 'English', 'es': 'Español', 'fr': 'Français', 'de': 'Deutsch', 'hi': 'हिन्दी'};

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _bioController = TextEditingController();
  final _countryController = TextEditingController();
  String _language = 'en';
  bool _darkMode = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      _countryController.text = user.country;
      _language = _languages.containsKey(user.language) ? user.language : 'en';
      _darkMode = user.darkModePreference;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final failure = await ref.read(authControllerProvider.notifier).updateProfile(
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
          language: _language,
          darkModePreference: _darkMode,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
    // On success the router redirect (needsProfileSetupProvider flips to
    // false) sends us to /dashboard itself — see core/router/app_router.dart.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(Icons.add_a_photo_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Firebase Storage upload is deferred (see product-spec
                    // non-goals) — wiring point is here once it lands.
                  },
                  child: const Text('Add profile picture'),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bioController,
                maxLength: 140,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Bio (optional)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: _languages.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _language = v ?? _language),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _finish,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enter Forge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
