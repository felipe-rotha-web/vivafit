import 'package:flutter_test/flutter_test.dart';
import 'package:appvivafit/src/data/auth_service.dart';
import 'package:appvivafit/src/data/conn.dart';
import 'package:appvivafit/src/models/app_user.dart';

void main() {
  test('deve apontar para os endpoints reais do backend', () {
    expect(Conn.baseUrl, startsWith('http'));
    expect(Conn.loginEndpoint, '/users/login');
    expect(Conn.registerEndpoint, '/users/register');
    expect(
      Conn.passwordResetRequestEndpoint,
      '/users/password-reset/request',
    );
    expect(
      Conn.passwordResetConfirmEndpoint,
      '/users/password-reset/confirm',
    );
    expect(Conn.editUserEndpoint(1), '/users/edit/1');
  });

  test('deve aceitar URL do backend via USB com adb reverse', () {
    const usbUrl = 'http://localhost:5000';

    expect(Conn.resolveBaseUrl(usbUrl), usbUrl);
    expect(Conn.baseUrl, startsWith('http://localhost'));
  });

  test('deve montar payload de login compatível com o backend', () {
    final payload = AuthService.buildLoginPayload('ana', '123456');

    expect(payload['nome'], 'ana');
    expect(payload['email'], 'ana');
    expect(payload['senha'], '123456');
  });

  test('deve enviar o email informado no cadastro à API', () {
    final usuario = AppUser(
      nome: 'Ana',
      email: 'ana@example.com',
      senha: '123456',
      idade: 30,
      genero: 'Feminino',
      nivelAtividade: 'Leve',
    );

    expect(
      AuthService.buildRegisterPayload(usuario)['email'],
      'ana@example.com',
    );
  });
}
