/// Base URL is overridable at build time:
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
///
/// Default targets the Android emulator's host-loopback alias so `flutter
/// run` against the local backend (see docker/docker-compose.yml) works out
/// of the box on Android without extra flags. iOS simulator and physical
/// devices need an explicit --dart-define override.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
