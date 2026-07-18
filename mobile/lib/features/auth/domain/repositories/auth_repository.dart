import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    required String timezone,
    required String country,
    required String language,
    required bool darkModePreference,
  });

  Future<Result<User>> login({required String email, required String password});

  Future<Result<void>> logout();

  Future<Result<User>> updateProfile({
    String? profilePictureUrl,
    String? timezone,
    String? country,
    String? language,
    bool? darkModePreference,
    String? bio,
  });

  /// Reads the cached session (does not hit the network). Returns null if no
  /// valid token pair is stored — the presentation layer treats that as
  /// "unauthenticated" and GoRouter redirects to /login.
  Future<User?> getCurrentUser();

  Future<bool> hasValidSession();
}
