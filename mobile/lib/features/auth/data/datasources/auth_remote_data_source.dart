import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthTokenPair {
  const AuthTokenPair({required this.accessToken, required this.refreshToken, required this.user});
  final String accessToken;
  final String refreshToken;
  final UserModel user;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);
  final ApiClient _client;

  Future<AuthTokenPair> register({
    required String username,
    required String email,
    required String password,
    required String timezone,
    required String country,
    required String language,
    required bool darkModePreference,
  }) async {
    final response = await _client.dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'timezone': timezone,
      'country': country,
      'language': language,
      'darkModePreference': darkModePreference,
    });
    return _parseTokenPair(response);
  }

  Future<AuthTokenPair> login({required String email, required String password}) async {
    final response = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _parseTokenPair(response);
  }

  Future<void> logout() async {
    await _client.dio.post('/auth/logout');
  }

  Future<UserModel> getMe() async {
    final response = await _client.dio.get('/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe(Map<String, dynamic> patch) async {
    final response = await _client.dio.patch('/users/me', data: patch);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  AuthTokenPair _parseTokenPair(Response response) {
    final data = response.data as Map<String, dynamic>;
    return AuthTokenPair(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});
