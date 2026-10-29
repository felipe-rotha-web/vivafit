 import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../theme.dart';
import 'conn.dart';

// Classe AuthService representa o serviço de autenticação do frontend.
class AuthService {
  AuthService._();

  static const String _tokenKey = 'vivafit_auth_token';

  // Notifier global que mantém o usuário autenticado disponível para outras telas.
  static final ValueNotifier<AppUser?> usuarioNotifier = ValueNotifier(null);

  // Retorna o usuário atualmente logado, ou null se nenhum usuário estiver autenticado.
  static AppUser? get usuarioLogado => usuarioNotifier.value;

  static Map<String, dynamic> buildLoginPayload(
    String nomeOuEmail,
    String senha,
  ) {
    final identificador = nomeOuEmail.trim();
    final senhaTrim = senha.trim();

    return {'nome': identificador, 'email': identificador, 'senha': senhaTrim};
  }

  static Map<String, dynamic> buildRegisterPayload(AppUser novoUsuario) {
    final nome = novoUsuario.nome.trim();

    return {
      'nome': nome,
      'email': novoUsuario.email.trim(),
      'senha': novoUsuario.senha.trim(),
      'confirmsenha': novoUsuario.senha.trim(),
      'phone': '00000000000',
      'idade': novoUsuario.idade,
      'nascimento': '2000-01-01',
      'altura': novoUsuario.altura ?? 1.7,
      'peso': novoUsuario.peso ?? 70.0,
      'genero': novoUsuario.genero,
      'lvl_atividade': novoUsuario.nivelAtividade,
      'lvl_adm': '0',
      'points': 0,
      'crono_hydro': 0,
      'dias_itensivos': '0',
    };
  }

  static Future<AppUser?> login({
    required String email,
    required String senha,
  }) async {
    if (email.trim().isEmpty || senha.trim().isEmpty) {
      return null;
    }

    final response = await http.post(
      Uri.parse('${Conn.baseUrl}${Conn.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(buildLoginPayload(email, senha)),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final userMap = decoded['user'] as Map<String, dynamic>?;
      final token = decoded['token'] as String?;

      if (userMap == null) {
        return null;
      }

      await _saveSession(token, userMap, senha);
      return _mapToAppUser(userMap, senha: senha);
    }

    final message = decoded['message'] ?? 'Credenciais inválidas';
    throw Exception(message);
  }

  static Future<bool> cadastrar(AppUser novoUsuario) async {
    final payload = buildRegisterPayload(novoUsuario);

    final response = await http.post(
      Uri.parse('${Conn.baseUrl}${Conn.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final userMap = decoded['user'] as Map<String, dynamic>? ?? payload;
      final token = decoded['token'] as String?;
      await _saveSession(token, userMap, novoUsuario.senha);
      return true;
    }

    final message = decoded['message'] ?? 'Falha ao cadastrar usuário';
    if (response.statusCode == 422 &&
        message.toString().toLowerCase().contains('já existe')) {
      return false;
    }

    throw Exception(message);
  }

  static Future<String> requestPasswordResetCode({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${Conn.baseUrl}${Conn.passwordResetRequestEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['message'] ?? 'Falha ao solicitar código.');
    }
    return (decoded['message'] ?? 'Solicitação processada.').toString();
  }

  static Future<String> confirmPasswordReset({
    required String email,
    required String code,
    required String novaSenha,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${Conn.baseUrl}${Conn.passwordResetConfirmEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'code': code.trim(),
        'novaSenha': novaSenha,
      }),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['message'] ?? 'Falha ao redefinir senha.');
    }
    return (decoded['message'] ?? 'Senha redefinida com sucesso.').toString();
  }

  static AppUser _mapToAppUser(Map<String, dynamic> row, {String? senha}) {
    return AppUser(
      id: int.tryParse((row['id'] ?? '').toString()),
      nome: (row['nome'] ?? '').toString(),
      email: (row['email'] ?? '').toString(),
      senha: senha ?? (row['senha'] ?? '').toString(),
      idade: int.tryParse((row['idade'] ?? '0').toString()) ?? 0,
      genero: (row['genero'] ?? 'Outro').toString(),
      nivelAtividade:
          (row['lvl_atividade'] ?? row['nivelAtividade'] ?? 'Sedentário')
              .toString(),
      peso: double.tryParse((row['peso'] ?? '0').toString()),
      altura: double.tryParse((row['altura'] ?? '0').toString()),
    );
  }

  static Future<void> _saveSession(
    String? token,
    Map<String, dynamic> userMap,
    String senha,
  ) async {
    final normalizedToken = token?.trim();
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, normalizedToken);
    }

    final backendThemeMode = userMap['theme_mode']?.toString();
    final backendDaltonism = userMap['daltonism_variant']?.toString();
    if (backendThemeMode != null || backendDaltonism != null) {
      await AppThemeController.applyRemotePreferences(
        themeMode: backendThemeMode,
        daltonismVariantValue: backendDaltonism,
      );
    }

    usuarioNotifier.value = _mapToAppUser(userMap, senha: senha);
  }

  static Future<void> updateProfile({
    required String nome,
    required String email,
  }) async {
    final usuario = usuarioNotifier.value;
    final userId = usuario?.id;
    if (usuario == null || userId == null) {
      throw Exception('Não foi possível identificar o usuário autenticado.');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey)?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('Sua sessão expirou. Faça login novamente.');
    }

    final response = await http.patch(
      Uri.parse('${Conn.baseUrl}${Conn.editUserEndpoint(userId)}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nome': nome.trim(), 'email': email.trim()}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? 'Falha ao atualizar perfil';
      throw Exception(message);
    }

    usuarioNotifier.value = AppUser(
      id: usuario.id,
      nome: nome.trim(),
      email: email.trim(),
      senha: usuario.senha,
      idade: usuario.idade,
      genero: usuario.genero,
      nivelAtividade: usuario.nivelAtividade,
      peso: usuario.peso,
      altura: usuario.altura,
    );
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      usuarioNotifier.value = null;
      return;
    }

    usuarioNotifier.value =
        usuarioNotifier.value ??
        AppUser(
          nome: 'Usuário',
          senha: '',
          idade: 0,
          genero: 'Outro',
          nivelAtividade: 'Sedentário',
        );
  }

  static void updateUsuario(AppUser usuario) {
    usuarioNotifier.value = usuario;
  }

  static void logout() {
    usuarioNotifier.value = null;
  }
}
