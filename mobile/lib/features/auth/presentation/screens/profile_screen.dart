import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/forge_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../categories/presentation/providers/categories_controller.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../../export/presentation/providers/export_controller.dart';
import '../../../habits/presentation/providers/habits_controller.dart';
import '../../../journal/presentation/providers/journal_controller.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_controller.dart';

const _languages = {'en': 'English', 'es': 'Español', 'fr': 'Français', 'de': 'Deutsch', 'hi': 'हिन्दी'};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const LoadingView(),
        error: (_, __) => const Center(child: Text("Couldn't load your profile.")),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AccountHeader(user: user),
                const SizedBox(height: 24),
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ForgeCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('Edit profile'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openEditProfile(context, ref, user),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text('Theme'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/settings/theme'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Data', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const _DataSection(),
                const SizedBox(height: 24),
                Text('Security', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ForgeCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded),
                        title: const Text('Change password'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _openChangePassword(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: const Text('Log out'),
                        onTap: () => _confirmLogout(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                        title: Text('Delete account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        onTap: () => _confirmDeleteAccount(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditProfile(BuildContext context, WidgetRef ref, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(user: user),
    );
  }

  void _openChangePassword(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently disables your account and signs you out everywhere. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final failure = await ref.read(authControllerProvider.notifier).deleteAccount();
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}

/// Export writes a JSON backup to a temp file and hands it to the OS share
/// sheet; import restores one. Both are additive server-side (see
/// ExportService#importData) — re-importing the same file never overwrites
/// existing data, so there's no destructive-action confirmation needed here.
class _DataSection extends ConsumerStatefulWidget {
  const _DataSection();

  @override
  ConsumerState<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<_DataSection> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);
    final failure = await ref.read(exportControllerProvider).exportToFile();
    if (!mounted) return;
    setState(() => _isExporting = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _import() async {
    setState(() => _isImporting = true);
    final failure = await ref.read(exportControllerProvider).importFromFile();
    if (!mounted) return;
    setState(() => _isImporting = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    // Refresh every list that could now contain imported rows.
    ref.invalidate(categoriesControllerProvider);
    ref.invalidate(habitsControllerProvider);
    ref.invalidate(journalControllerProvider);
    ref.invalidate(dashboardControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup imported')));
  }

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Export data'),
            trailing: _isExporting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right_rounded),
            onTap: _isExporting ? null : _export,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import data'),
            trailing: _isImporting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right_rounded),
            onTap: _isImporting ? null : _import,
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForgeCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: theme.textTheme.titleLarge),
                Text(user.email, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Level ${user.level} · ${user.xp} XP · Member since ${DateFormat.yMMM().format(user.memberSince)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.user});
  final User user;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final _bioController = TextEditingController(text: widget.user.bio ?? '');
  late final _countryController = TextEditingController(text: widget.user.country);
  late String _language = _languages.containsKey(widget.user.language) ? widget.user.language : 'en';
  late bool _darkMode = widget.user.darkModePreference;
  bool _saving = false;

  @override
  void dispose() {
    _bioController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final failure = await ref.read(authControllerProvider.notifier).updateProfile(
          bio: _bioController.text.trim(),
          country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
          language: _language,
          darkModePreference: _darkMode,
        );
    if (!mounted) return;
    if (failure != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _bioController,
            maxLength: 140,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          TextField(
            controller: _countryController,
            decoration: const InputDecoration(labelText: 'Country'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _language,
            decoration: const InputDecoration(labelText: 'Language'),
            items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _language = v ?? _language),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark mode'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const LoadingView(compact: true) : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = "New passwords don't match");
      return;
    }
    if (_newController.text.length < 8) {
      setState(() => _error = 'New password must be at least 8 characters');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final failure = await ref.read(authControllerProvider.notifier).changePassword(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _saving = false;
        _error = failure.message;
      });
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed. You have been signed out on other devices.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change Password', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _currentController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm new password'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const LoadingView(compact: true) : const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }
}
