import '../../../../core/error/result.dart';
import '../entities/furnace_ember.dart';

abstract class FurnaceRepository {
  Future<Result<List<FurnaceEmber>>> listEmbers();

  Future<Result<FurnaceReforgeResult>> reforge(String habitId);
}
