/// Base URL is overridable at build time:
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
///
/// Defaults to the hosted Render backend so a plain `flutter run`/release
/// build works on a real device without extra flags. For local-backend
/// development (see docker/docker-compose.yml), override with
/// http://10.0.2.2:8080/api/v1 (Android emulator) or http://localhost:8080/api/v1
/// (iOS simulator/desktop).
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://forge-bfja.onrender.com/api/v1',
  );

  // Render's free tier spins the backend down when idle; waking it from a
  // full cold start can take up to ~60-90s, so these need enough headroom
  // to cover that rather than timing out mid-wake and surfacing a spurious
  // "no internet connection" error.
  static const Duration connectTimeout = Duration(seconds: 90);
  static const Duration receiveTimeout = Duration(seconds: 90);
}
