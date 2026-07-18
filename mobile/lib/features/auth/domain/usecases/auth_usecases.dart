import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Grouped in one file since each use case here is a thin, single-line
/// pass-through to the repository — splitting them into 4 files would add
/// navigation overhead without adding clarity. Split out the moment one of
/// these grows real orchestration logic (e.g. LoginUseCase later coordinating
/// FCM device registration after a successful login).
class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<User>> call({
    required String username,
    required String email,
    required String password,
    required String timezone,
    required String country,
    required String language,
    required bool darkModePreference,
  }) {
    return _repository.register(
      username: username,
      email: email,
      password: password,
      timezone: timezone,
      country: country,
      language: language,
      darkModePreference: darkModePreference,
    );
  }
}

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<User>> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<User?> call() => _repository.getCurrentUser();
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<User>> call({
    String? profilePictureUrl,
    String? timezone,
    String? country,
    String? language,
    bool? darkModePreference,
    String? bio,
  }) {
    return _repository.updateProfile(
      profilePictureUrl: profilePictureUrl,
      timezone: timezone,
      country: country,
      language: language,
      darkModePreference: darkModePreference,
      bio: bio,
    );
  }
}
