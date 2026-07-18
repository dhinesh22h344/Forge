import '../../../../core/error/result.dart';
import '../entities/achievement.dart';

abstract class AchievementRepository {
  Future<Result<List<Achievement>>> list();
}
