import 'package:flutter/foundation.dart';

// Classe Conn representa o ponto de conexão com a API do backend.
class Conn {
  Conn._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Para celular físico via USB, use o adb reverse e configure:
  // flutter run --dart-define=API_BASE_URL=http://localhost:5000
  // Também funciona com IP da máquina, por exemplo:
  // --dart-define=API_BASE_URL=http://192.168.0.10:5000
  static String resolveBaseUrl([String? override]) {
    final value = (override ?? _configuredBaseUrl).trim();
    if (value.isNotEmpty) {
      return value;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    // Para celular físico via USB, usa o adb reverse e o backend em localhost.
    // Ex.: adb reverse tcp:5000 tcp:5000
    return 'http://localhost:5000';
  }

  static String get baseUrl => resolveBaseUrl();

  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String passwordResetRequestEndpoint =
      '/users/password-reset/request';
  static const String passwordResetConfirmEndpoint =
      '/users/password-reset/confirm';
  static String editUserEndpoint(int id) => '/users/edit/$id';
}
