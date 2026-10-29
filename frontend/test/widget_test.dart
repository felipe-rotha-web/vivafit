// Arquivo: widget_test.dart
// Descreve o propósito deste arquivo no projeto AppVivaFit.

import 'package:appvivafit/src/app.dart';
import 'package:appvivafit/src/models/app_user.dart';
import 'package:appvivafit/src/pages/cronograma_page.dart';
import 'package:appvivafit/src/pages/desafios_page.dart';
import 'package:appvivafit/src/pages/lembretes_page.dart';
import 'package:appvivafit/src/pages/login_page.dart';
import 'package:appvivafit/src/pages/perfil_page.dart';
import 'package:appvivafit/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Função main executa uma ação nesta classe.
void main() {
  testWidgets('mostra a tela inicial do AppVivaFit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AppVivaFit());

    expect(find.text('AppVivaFit'), findsOneWidget);
    expect(find.text('Sua jornada de saúde começa aqui'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Cadastrar Usuário'), findsOneWidget);
  });

  testWidgets('a tela de login solicita email', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == 'Email',
      ),
      findsOneWidget,
    );
  });

  testWidgets('recuperação exige email verificado antes da nova senha', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.ensureVisible(find.text('Esqueceu sua senha?'));
    await tester.tap(find.text('Esqueceu sua senha?'));
    await tester.pumpAndSettle();

    expect(find.text('Email da sua conta'), findsOneWidget);
    expect(find.text('Enviar código'), findsOneWidget);
    expect(find.text('Nova senha (mínimo 8 caracteres)'), findsNothing);
    expect(find.text('Nome de usuário'), findsNothing);
  });

  testWidgets('o perfil mostra o email abaixo do nome', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const usuario = AppUser(
      nome: 'Ana',
      email: 'ana@example.com',
      senha: '',
      idade: 30,
      genero: 'Feminino',
      nivelAtividade: 'Leve',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PerfilPage(usuario: usuario)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
  });

  test('ordena tarefas por horário', () {
    final tarefas = [
      {'titulo': '11:00', 'hora': '11:00 - 12:00'},
      {'titulo': '09:00', 'hora': '09:00 - 10:00'},
      {'titulo': '10:30', 'hora': '10:30 - 11:30'},
    ];

    final ordenadas = CronogramaPage.ordenarTarefas(tarefas);

    expect(ordenadas.map((t) => t['titulo']).toList(), [
      '09:00',
      '10:30',
      '11:00',
    ]);
  });

  test('ordena lembretes por horário', () {
    final lembretes = [
      {'titulo': '11:00', 'hora': '11:00'},
      {'titulo': '09:00', 'hora': '09:00'},
      {'titulo': '10:30', 'hora': '10:30'},
    ];

    final ordenados = LembretesPage.ordenarLembretes(lembretes);

    expect(ordenados.map((l) => l['titulo']).toList(), [
      '09:00',
      '10:30',
      '11:00',
    ]);
  });

  testWidgets(
    'desafios concluídos não aparecem nas listas de ativos ou disponíveis',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DesafiosPage()));

      final state = tester.state(find.byType(DesafiosPage)) as dynamic;
      state.concluirDesafio(0);
      await tester.pump();

      expect(
        state.desafiosAtivos.any(
          (desafio) => desafio['titulo'] == 'Semana Fitness',
        ),
        isFalse,
      );
      expect(
        state.desafiosDisponiveis.any(
          (desafio) => desafio['titulo'] == 'Semana Fitness',
        ),
        isFalse,
      );
    },
  );

  testWidgets('o diálogo de edição do lembrete abre em modo de edição', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LembretesPage())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    expect(find.text('Editar lembrete'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  test('as cores semânticas obedecem ao tema acessível', () {
    final normalSuccess = AppColors.success;
    final normalWarning = AppColors.warning;
    final normalError = AppColors.error;
    final normalInfo = AppColors.info;

    AppThemeController.mode.value = AppThemeMode.accessible;
    AppThemeController.daltonismVariant.value = DaltonismVariant.deuteranopia;

    expect(AppColors.success, isNot(equals(normalSuccess)));
    expect(AppColors.warning, isNot(equals(normalWarning)));
    expect(AppColors.error, isNot(equals(normalError)));
    expect(AppColors.info, isNot(equals(normalInfo)));

    AppThemeController.mode.value = AppThemeMode.normal;
    AppThemeController.daltonismVariant.value = DaltonismVariant.deuteranopia;
  });
}
