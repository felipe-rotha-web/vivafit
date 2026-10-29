import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appvivafit/src/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('deve alternar entre tema normal e acessível', () async {
    AppThemeController.mode.value = AppThemeMode.normal;
    await AppThemeController.setMode(AppThemeMode.accessible);

    expect(AppThemeController.mode.value, AppThemeMode.accessible);
  });

  test('deve aceitar e persistir o tema escuro', () async {
    AppThemeController.mode.value = AppThemeMode.normal;
    await AppThemeController.setMode(AppThemeMode.dark);

    expect(AppThemeController.mode.value, AppThemeMode.dark);
    expect(AppThemeController.parseMode('dark'), AppThemeMode.dark);
  });

  test('deve alternar entre variantes de daltonismo', () async {
    AppThemeController.daltonismVariant.value = DaltonismVariant.deuteranopia;
    await AppThemeController.setDaltonismVariant(DaltonismVariant.tritanopia);

    expect(AppThemeController.daltonismVariant.value, DaltonismVariant.tritanopia);
  });

  test('deve ajustar e persistir o tamanho de texto e espaçamento', () async {
    AppThemeController.fontScale.value = 1.0;
    AppThemeController.lineHeight.value = 1.0;

    await AppThemeController.setFontScale(1.25);
    await AppThemeController.setLineHeight(1.6);

    expect(AppThemeController.fontScale.value, 1.25);
    expect(AppThemeController.lineHeight.value, 1.6);
    expect(AppThemeController.normalizeFontScale(2.0), 1.5);
    expect(AppThemeController.normalizeLineHeight(3.0), 2.0);
  });

  test('deve ativar e persistir o destaque em negrito do texto', () async {
    AppThemeController.boldText.value = false;

    await AppThemeController.setBoldText(true);

    expect(AppThemeController.boldText.value, isTrue);
  });

  test('deve aplicar negrito nos estilos globais do tema quando o destaque estiver ativo', () async {
    AppThemeController.boldText.value = false;
    AppThemeController.boldText.value = true;

    final theme = AppTheme.theme(AppThemeMode.normal);

    expect(theme.textTheme.bodyMedium?.fontWeight, FontWeight.w700);
    expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w700);
  });
}
