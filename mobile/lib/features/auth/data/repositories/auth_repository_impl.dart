import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    required String timezone,
    required String country,
    required String language,
    required bool darkModePreference,
  }) async {
    try {
      final pair = await _remote.register(
        username: username,
        email: email,
        password: password,
        timezone: timezone,
        country: country,
        language: language,
        darkModePreference: darkModePreference,
      );
      await _tokenStorage.saveTokens(accessToken: pair.accessToken, refreshToken: pair.refreshToken);
      return Success(pair.user);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    }
  }

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    try {
      final pair = await _remote.login(email: email, password: password);
      await _tokenStorage.saveTokens(accessToken: pair.accessToken, refreshToken: pair.refreshToken);
      return Success(pair.user);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken != null) await _remote.logout(refreshToken);
    } on DioException {
      // Best-effort server-side revoke; local session is cleared regardless
      // so the user is never stuck logged-in on this device.
    }
    await _tokenStorage.clear();
    return const Success(null);
  }

  @override
  Future<Result<User>> updateProfile({
    String? profilePictureUrl,
    String? timezone,
    String? country,
    String? language,
    bool? darkModePreference,
    String? bio,
  }) async {
    try {
      final patch = <String, dynamic>{
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (timezone != null) 'timezone': timezone,
        if (country != null) 'country': country,
        if (language != null) 'language': language,
        if (darkModePreference != null) 'darkModePreference': darkModePreference,
        if (bio != null) 'bio': bio,
      };
      final user = await _remote.updateMe(patch);
      return Success(user);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!await hasValidSession()) return null;
    try {
      return await _remote.getMe();
    } on DioException {
      return null;
    }
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null;
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _remote.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return const Success(null);
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
    } on DioException catch (e) {
      return Error(_mapDioError(e));
    }
    await _tokenStorage.clear();
    return const Success(null);
  }

  Failure _mapDioError(DioException e) {
    final response = e.response;
    if (response == null) return const NetworkFailure();
    if (response.statusCode == 401) {
      final body = response.data;
      final message = body is Map ? body['message'] as String? : null;
      return UnauthorizedFailure(message ?? 'Invalid email or password');
    }
    if (response.statusCode == 400) {
      final body = response.data;
      if (body is Map && body['fieldErrors'] is List) {
        final errors = <String, String>{
          for (final fe in body['fieldErrors'] as List)
            (fe['field'] as String): (fe['message'] as String),
        };
        return ValidationFailure(body['message'] as String? ?? 'Validation failed', fieldErrors: errors);
      }
      return const ValidationFailure('Please check your input');
    }
    if (response.statusCode == 409) return const ValidationFailure('Email already registered');
    return ServerFailure('Server error, please try again', statusCode: response.statusCode);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider), ref.watch(tokenStorageProvider));
});
