import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/token_storage.dart';

/// Tracks which unlocked achievement codes the user has already been shown
/// the unlock animation for, so re-opening the Achievements screen doesn't
/// replay it for things they've already seen. Backed by the same secure
/// storage as auth tokens — this is a small, non-sensitive local flag, not
/// worth its own storage mechanism.
class SeenAchievementsStore {
  const SeenAchievementsStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _key = 'forge_seen_achievement_codes';

  Future<Set<String>> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  Future<void> markSeen(Set<String> codes) async {
    if (codes.isEmpty) return;
    final current = await read();
    final merged = {...current, ...codes};
    await _storage.write(key: _key, value: merged.join(','));
  }
}

final seenAchievementsStoreProvider = Provider<SeenAchievementsStore>((ref) {
  return SeenAchievementsStore(ref.watch(secureStorageProvider));
});
