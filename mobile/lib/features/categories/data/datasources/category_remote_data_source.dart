import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryRemoteDataSource {
  const CategoryRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<CategoryModel>> list() async {
    final response = await _client.dio.get('/categories');
    return (response.data as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> create(Map<String, dynamic> body) async {
    final response = await _client.dio.post('/categories', data: body);
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CategoryModel> update(String id, Map<String, dynamic> body) async {
    final response = await _client.dio.put('/categories/$id', data: body);
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/categories/$id');
  }
}

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource(ref.watch(apiClientProvider));
});
