import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/personal_records_model.dart';

class RecordsRemoteDataSource {
  const RecordsRemoteDataSource(this._client);
  final ApiClient _client;

  Future<PersonalRecordsModel> get() async {
    final response = await _client.dio.get('/records');
    return PersonalRecordsModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final recordsRemoteDataSourceProvider = Provider<RecordsRemoteDataSource>((ref) {
  return RecordsRemoteDataSource(ref.watch(apiClientProvider));
});
