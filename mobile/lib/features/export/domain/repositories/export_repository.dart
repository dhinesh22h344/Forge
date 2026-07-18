import '../../../../core/error/result.dart';

/// Deliberately works with raw JSON rather than a domain entity — the backup
/// payload is never rendered in the UI, only written to/read from a file, so
/// there's nothing for a typed entity to buy here (see ADR note in
/// ExportRepositoryImpl).
abstract class ExportRepository {
  Future<Result<Map<String, dynamic>>> export();

  Future<Result<void>> importJson(Map<String, dynamic> payload);
}
