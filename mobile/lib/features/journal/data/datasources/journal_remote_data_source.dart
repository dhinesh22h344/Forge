import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/journal_entry_model.dart';

class JournalRemoteDataSource {
  const JournalRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<JournalEntryModel>> list({DateTime? from, DateTime? to}) async {
    final response = await _client.dio.get('/journal', queryParameters: {
      if (from != null) 'from': _dateOnly(from),
      if (to != null) 'to': _dateOnly(to),
    });
    return (response.data as List).map((e) => JournalEntryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<JournalEntryModel> get(DateTime date) async {
    final response = await _client.dio.get('/journal/${_dateOnly(date)}');
    return JournalEntryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<JournalEntryModel> upsert(DateTime date, Map<String, dynamic> body) async {
    final response = await _client.dio.put('/journal/${_dateOnly(date)}', data: body);
    return JournalEntryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(DateTime date) async {
    await _client.dio.delete('/journal/${_dateOnly(date)}');
  }

  String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}

final journalRemoteDataSourceProvider = Provider<JournalRemoteDataSource>((ref) {
  return JournalRemoteDataSource(ref.watch(apiClientProvider));
});
