import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Single source of truth for "who is logged in". `null` data means
/// unauthenticated (not loading) — the router redirect guard reads this
/// distinction directly, so it must never be conflated with AsyncLoading.
class AuthController extends AsyncNotifier<User?> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  @override
  Future<User?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    _registerUseCase = RegisterUseCase(repository);
    _loginUseCase = LoginUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    return _getCurrentUserUseCase();
  }

  Future<Failure?> register({
    required String username,
    required String email,
    required String password,
    required String timezone,
    required String country,
    required String language,
    required bool darkModePreference,
  }) async {
    state = const AsyncLoading();
    final result = await _registerUseCase(
      username: username,
      email: email,
      password: password,
      timezone: timezone,
      country: country,
      language: language,
      darkModePreference: darkModePreference,
    );
    return result.when(
      success: (user) {
        state = AsyncData(user);
        ref.read(needsProfileSetupProvider.notifier).state = true;
        return null;
      },
      failure: (failure) {
        state = AsyncData(state.value);
        return failure;
      },
    );
  }

  Future<Failure?> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await _loginUseCase(email: email, password: password);
    return result.when(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (failure) {
        state = AsyncData(state.value);
        return failure;
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = const AsyncData(null);
    ref.read(needsProfileSetupProvider.notifier).state = false;
  }

  Future<Failure?> updateProfile({
    String? profilePictureUrl,
    String? timezone,
    String? country,
    String? language,
    bool? darkModePreference,
    String? bio,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await UpdateProfileUseCase(repository).call(
      profilePictureUrl: profilePictureUrl,
      timezone: timezone,
      country: country,
      language: language,
      darkModePreference: darkModePreference,
      bio: bio,
    );
    return result.when(
      success: (user) {
        state = AsyncData(user);
        ref.read(needsProfileSetupProvider.notifier).state = false;
        return null;
      },
      failure: (failure) => failure,
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);

/// True from the moment register() succeeds until updateProfile() is called
/// (Create Profile screen's "Enter Forge" action) or the user logs out. The
/// router redirect reads this to force new registrations through Create
/// Profile — it owns that transition instead of screens calling context.go,
/// which raced against the auth-state-driven redirect (both fired off the
/// same state change, and whichever ran second silently won).
final needsProfileSetupProvider = StateProvider<bool>((ref) => false);

/// True only once we have a definitive answer; router treats "still
/// resolving" (loading on first launch, before build() completes) as "stay
/// on splash" rather than bouncing to login and back.
final isAuthenticatedProvider = Provider<bool?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => null,
    error: (_, __) => false,
  );
});
