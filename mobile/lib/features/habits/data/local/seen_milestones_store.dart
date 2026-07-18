import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/token_storage.dart';

/// Tracks which "habitId:streakDay" milestone celebrations have already been
/// shown, so reopening a habit or completing it again doesn't replay the
/// celebration for a milestone already reached. Same secure-storage pattern
/// as SeenAchievementsStore — this is a small, non-sensitive local flag.
class SeenMilestonesStore {
  const SeenMilestonesStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _key = 'forge_seen_streak_milestones';

  Future<Set<String>> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  Future<void> markSeen(String milestoneKey) async {
    final current = await read();
    final merged = {...current, milestoneKey};
    await _storage.write(key: _key, value: merged.join(','));
  }
}

final seenMilestonesStoreProvider = Provider<SeenMilestonesStore>((ref) {
  return SeenMilestonesStore(ref.watch(secureStorageProvider));
});
