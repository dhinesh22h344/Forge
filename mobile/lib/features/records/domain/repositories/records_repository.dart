import '../../../../core/error/result.dart';
import '../entities/personal_records.dart';

abstract class RecordsRepository {
  Future<Result<PersonalRecords>> get();
}
