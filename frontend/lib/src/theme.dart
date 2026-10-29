
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe AppColors representa um componente ou widget da interface.
class AppColors {
  AppColors._();

  static const _primary = Color(0xFF21283B);
  static const _secondary = Color(0xFF255359);
  static const _success = Color(0xFF479F80);
  static const _warning = Color(0xFFF78660);
  static const _info = Color(0xFF255359);
  static const _reward = Color(0xFFF78660);
  static const _surface = Color(0xFFFCF5FA);

  static const _darkPrimary = Color(0xFF101827);
  static const _darkSecondary = Color(0xFF1F2937);
  static const _darkSurface = Color(0xFF0F172A);
  static const _darkSuccess = Color(0xFF6EE7B7);
  static const _darkWarning = Color(0xFFFBBF24);
  static const _darkInfo = Color(0xFF7DD3FC);
  static const _darkReward = Color(0xFFF59E0B);

  // legacy accessible* constants removed — using daltonism palettes instead

  // Daltonismo — Deuteranopia, Tritanopia, Acromatopsia
  // Deuteranopia
  static const daltonismDeuteranopiaPrimary = Color(0xFF232335);
  static const daltonismDeuteranopiaSecondary = Color(0xFF363257);
  static const daltonismDeuteranopiaSuccess = Color(0xFF686189);
  static const daltonismDeuteranopiaSurface = Color(0xFFF9F9F8);
  static const daltonismDeuteranopiaAccent = Color(0xFFCCD56B);

  // Tritanopia
  static const daltonismTritanopiaPrimary = Color(0xFF213231);
  static const daltonismTritanopiaSecondary = Color(0xFF275656);
  static const daltonismTritanopiaSuccess = Color(0xFF4B8D8E);
  static const daltonismTritanopiaSurface = Color(0xFFFBF7F7);
  static const daltonismTritanopiaAccent = Color(0xFFF17072);

  // Acromatopsia 
  static const daltonismAcromatopsiaPrimary = Color(0xFF282828);
  static const daltonismAcromatopsiaSecondary = Color(0xFF454545);
  static const daltonismAcromatopsiaSuccess = Color(0xFF818181);
  static const daltonismAcromatopsiaSurface = Color(0xFFF7F7F7);
  static const daltonismAcromatopsiaAccent = Color(0xFFA3A3A3);

  static Color get primary => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismPrimary(),
        AppThemeMode.dark => _darkPrimary,
        AppThemeMode.normal => _primary,
      };

  static Color get secondary => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismSecondary(),
        AppThemeMode.dark => _darkSecondary,
        AppThemeMode.normal => _secondary,
      };

  static Color get surface => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismSurface(),
        AppThemeMode.dark => _darkSurface,
        AppThemeMode.normal => _surface,
      };

  static Color get onPrimary => switch (AppThemeController.mode.value) {
        AppThemeMode.dark => Colors.white,
        AppThemeMode.accessible => _daltonismOnPrimary(),
        AppThemeMode.normal => Colors.white,
      };

  static Color get onSurface => switch (AppThemeController.mode.value) {
        AppThemeMode.dark => Colors.white,
        AppThemeMode.accessible => _daltonismOnSurface(),
        AppThemeMode.normal => const Color(0xFF21283B),
      };

  // Preserve API compatibility while allowing each semantic color to react to
  // the chosen accessible theme and daltonism variant at runtime.
  static Color get success => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismSuccess(),
        AppThemeMode.dark => _darkSuccess,
        AppThemeMode.normal => _success,
      };

  static Color get warning => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => daltonismAccent,
        AppThemeMode.dark => _darkWarning,
        AppThemeMode.normal => _warning,
      };

  static Color get info => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismSecondary(),
        AppThemeMode.dark => _darkInfo,
        AppThemeMode.normal => _info,
      };

  static Color get reward => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => daltonismAccent,
        AppThemeMode.dark => _darkReward,
        AppThemeMode.normal => _reward,
      };

  static Color get error => switch (AppThemeController.mode.value) {
        AppThemeMode.accessible => _daltonismError(),
        AppThemeMode.dark => const Color(0xFFEF5350),
        AppThemeMode.normal => const Color(0xFFD32F2F),
      };

    // Dynamic variants (use these where UI should follow accessible mode)
    static Color get successForMode => success;
    static Color get warningForMode => warning;
    static Color get infoForMode => info;
    static Color get rewardForMode => reward;

  // Funções auxiliares que retornam cores com base na variante de daltonismo atualmente selecionada.
  static Color _daltonismPrimary() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return daltonismTritanopiaPrimary;
      case DaltonismVariant.acromatopsia:
        return daltonismAcromatopsiaPrimary;
      default:
        return daltonismDeuteranopiaPrimary;
    }
  }

  static Color _daltonismSecondary() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return daltonismTritanopiaSecondary;
      case DaltonismVariant.acromatopsia:
        return daltonismAcromatopsiaSecondary;
      default:
        return daltonismDeuteranopiaSecondary;
    }
  }

  static Color _daltonismSurface() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return daltonismTritanopiaSurface;
      case DaltonismVariant.acromatopsia:
        return daltonismAcromatopsiaSurface;
      default:
        return daltonismDeuteranopiaSurface;
    }
  }

  static Color _daltonismOnPrimary() {
    // Escolha `onPrimary` para contraste — branco para cores primárias mais escuras, preto para as demais.
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.acromatopsia:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  static Color _daltonismOnSurface() {
    // Em temas acessíveis, as superfícies principais continuam claras para manter
    // contrastes legíveis em cards, listas e textos de conteúdo.
    return Colors.black;
  }

  static Color _daltonismSuccess() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return daltonismTritanopiaSuccess;
      case DaltonismVariant.acromatopsia:
        return daltonismAcromatopsiaSuccess;
      default:
        return daltonismDeuteranopiaSuccess;
    }
  }

  static Color _daltonismError() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return const Color(0xFFB85C5C);
      case DaltonismVariant.acromatopsia:
        return const Color(0xFF6B6B6B);
      default:
        return const Color(0xFF9D3C3C);
    }
  }

  //Cor de destaque para a variante atual de daltonismo
  static Color get daltonismAccent => _daltonismAccent();

  static Color _daltonismAccent() {
    switch (AppThemeController.daltonismVariant.value) {
      case DaltonismVariant.tritanopia:
        return daltonismTritanopiaAccent;
      case DaltonismVariant.acromatopsia:
        return daltonismAcromatopsiaAccent;
      default:
        return daltonismDeuteranopiaAccent;
    }
  }
}

// Enum AppThemeMode define um conjunto de valores nomeados.
enum AppThemeMode { normal, dark, accessible }

// Enum das variantes de daltonismo suportadas.
enum DaltonismVariant { deuteranopia, tritanopia, acromatopsia }

// Classe AppThemeController representa um componente ou widget da interface.
class AppThemeController {
  AppThemeController._();

  static const String _modeKey = 'app_theme_mode';
  static const String _daltonismKey = 'app_daltonism_variant';
  static const String _fontScaleKey = 'app_accessibility_font_scale';
  static const String _lineHeightKey = 'app_accessibility_line_height';
  static const String _boldTextKey = 'app_accessibility_bold_text';

  static final ValueNotifier<AppThemeMode> mode = ValueNotifier(
    AppThemeMode.normal,
  );

  // Variante de daltonismo selecionada (usada quando mode == accessible)
  static final ValueNotifier<DaltonismVariant> daltonismVariant =
      ValueNotifier(DaltonismVariant.deuteranopia);

  static final ValueNotifier<double> fontScale = ValueNotifier(1.0);
  static final ValueNotifier<double> lineHeight = ValueNotifier(1.4);
  static final ValueNotifier<bool> boldText = ValueNotifier(false);

  static double normalizeFontScale(double value) {
    return value.clamp(1.0, 1.5);
  }

  static double normalizeLineHeight(double value) {
    return value.clamp(1.0, 2.0);
  }

  static Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMode = prefs.getString(_modeKey);
    if (savedMode != null) {
      mode.value = parseMode(savedMode);
    }

    final savedVariant = prefs.getString(_daltonismKey);
    if (savedVariant != null) {
      daltonismVariant.value = parseDaltonismVariant(savedVariant);
    }

    final savedFontScale = prefs.getDouble(_fontScaleKey);
    if (savedFontScale != null) {
      fontScale.value = normalizeFontScale(savedFontScale);
    }

    final savedLineHeight = prefs.getDouble(_lineHeightKey);
    if (savedLineHeight != null) {
      lineHeight.value = normalizeLineHeight(savedLineHeight);
    }

    final savedBoldText = prefs.getBool(_boldTextKey);
    if (savedBoldText != null) {
      boldText.value = savedBoldText;
    }
  }

  static Future<void> applyRemotePreferences({
    String? themeMode,
    String? daltonismVariantValue,
    String? fontScaleValue,
    String? lineHeightValue,
    String? boldTextValue,
  }) async {
    if (themeMode != null && themeMode.isNotEmpty) {
      mode.value = parseMode(themeMode);
    }

    if (daltonismVariantValue != null && daltonismVariantValue.isNotEmpty) {
      daltonismVariant.value = parseDaltonismVariant(daltonismVariantValue);
    }

    if (fontScaleValue != null && fontScaleValue.isNotEmpty) {
      fontScale.value = normalizeFontScale(double.tryParse(fontScaleValue) ?? 1.0);
    }

    if (lineHeightValue != null && lineHeightValue.isNotEmpty) {
      lineHeight.value = normalizeLineHeight(double.tryParse(lineHeightValue) ?? 1.4);
    }

    if (boldTextValue != null && boldTextValue.isNotEmpty) {
      boldText.value = boldTextValue.toLowerCase() == 'true';
    }

    final prefs = await SharedPreferences.getInstance();
    if (themeMode != null && themeMode.isNotEmpty) {
      await prefs.setString(_modeKey, themeMode);
    }
    if (daltonismVariantValue != null && daltonismVariantValue.isNotEmpty) {
      await prefs.setString(_daltonismKey, daltonismVariantValue);
    }
    if (fontScaleValue != null && fontScaleValue.isNotEmpty) {
      await prefs.setDouble(_fontScaleKey, fontScale.value);
    }
    if (lineHeightValue != null && lineHeightValue.isNotEmpty) {
      await prefs.setDouble(_lineHeightKey, lineHeight.value);
    }
    if (boldTextValue != null && boldTextValue.isNotEmpty) {
      await prefs.setBool(_boldTextKey, boldText.value);
    }
  }

  static Future<void> setMode(AppThemeMode newMode) async {
    mode.value = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, newMode.name);
  }

  static Future<void> setDaltonismVariant(DaltonismVariant newVariant) async {
    daltonismVariant.value = newVariant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_daltonismKey, newVariant.name);
  }

  static Future<void> setFontScale(double newValue) async {
    fontScale.value = normalizeFontScale(newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, fontScale.value);
  }

  static Future<void> setLineHeight(double newValue) async {
    lineHeight.value = normalizeLineHeight(newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, lineHeight.value);
  }

  static Future<void> setBoldText(bool enabled) async {
    boldText.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_boldTextKey, enabled);
  }

  static AppThemeMode parseMode(String value) {
    switch (value) {
      case 'accessible':
        return AppThemeMode.accessible;
      case 'dark':
        return AppThemeMode.dark;
      case 'normal':
      default:
        return AppThemeMode.normal;
    }
  }

  static DaltonismVariant parseDaltonismVariant(String value) {
    switch (value) {
      case 'tritanopia':
        return DaltonismVariant.tritanopia;
      case 'acromatopsia':
        return DaltonismVariant.acromatopsia;
      case 'deuteranopia':
      default:
        return DaltonismVariant.deuteranopia;
    }
  }
}

// Classe AppTheme representa um componente ou widget da interface.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors._primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors._primary,
          secondary: AppColors._secondary,
          error: AppColors.error,
          surface: AppColors._surface,
          onPrimary: AppColors.onPrimary,
          onSurface: AppColors.onSurface,
        );

    return _applyAccessibilityTheme(
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        primaryColor: AppColors._primary,
        scaffoldBackgroundColor: AppColors._surface,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors._primary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.onPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors._primary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors._primary,
          selectedItemColor: AppColors.onPrimary,
          unselectedItemColor: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.onSurface.withAlpha((0.04 * 255).round()),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary.withAlpha((0.16 * 255).round()),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(
            color: AppColors.onSurface.withAlpha((0.72 * 255).round()),
          ),
          hintStyle: TextStyle(
            color: AppColors.onSurface.withAlpha((0.58 * 255).round()),
          ),
        ),
      ),
    );
  }

  static TextStyle _applyLineHeightToStyle(TextStyle? style, double height) {
    final baseStyle = style ?? const TextStyle();
    return baseStyle.copyWith(
      height: height,
    );
  }

  static TextTheme _applyLineHeightToTextTheme(TextTheme theme, double height) {
    return theme.copyWith(
      displayLarge: _applyLineHeightToStyle(theme.displayLarge, height),
      displayMedium: _applyLineHeightToStyle(theme.displayMedium, height),
      displaySmall: _applyLineHeightToStyle(theme.displaySmall, height),
      headlineLarge: _applyLineHeightToStyle(theme.headlineLarge, height),
      headlineMedium: _applyLineHeightToStyle(theme.headlineMedium, height),
      headlineSmall: _applyLineHeightToStyle(theme.headlineSmall, height),
      titleLarge: _applyLineHeightToStyle(theme.titleLarge, height),
      titleMedium: _applyLineHeightToStyle(theme.titleMedium, height),
      titleSmall: _applyLineHeightToStyle(theme.titleSmall, height),
      bodyLarge: _applyLineHeightToStyle(theme.bodyLarge, height),
      bodyMedium: _applyLineHeightToStyle(theme.bodyMedium, height),
      bodySmall: _applyLineHeightToStyle(theme.bodySmall, height),
      labelLarge: _applyLineHeightToStyle(theme.labelLarge, height),
      labelMedium: _applyLineHeightToStyle(theme.labelMedium, height),
      labelSmall: _applyLineHeightToStyle(theme.labelSmall, height),
    );
  }

  static ThemeData _applyControlHighlightTheme(ThemeData base, bool enabled) {
    if (!enabled) {
      return base;
    }

    final borderColor = base.colorScheme.primary.withAlpha((0.88 * 255).round());
    final subtleBorderColor = base.colorScheme.primary.withAlpha((0.34 * 255).round());
    final surfaceBorderColor = base.colorScheme.onSurface.withAlpha((0.20 * 255).round());

    return base.copyWith(
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: base.colorScheme.surface,
      cardTheme: base.cardTheme.copyWith(
        elevation: (base.cardTheme.elevation ?? 1) + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceBorderColor, width: 1.5),
        ),
      ),
      dividerColor: borderColor,
      dialogTheme: base.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: surfaceBorderColor, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          side: BorderSide(color: borderColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(borderColor),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return base.colorScheme.primary;
          }
          return base.colorScheme.onSurface.withAlpha((0.72 * 255).round());
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return base.colorScheme.primary.withAlpha((0.38 * 255).round());
          }
          return base.colorScheme.onSurface.withAlpha((0.16 * 255).round());
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return base.colorScheme.primary;
          }
          return base.colorScheme.surface;
        }),
        side: BorderSide(color: borderColor, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(base.colorScheme.primary),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: subtleBorderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: subtleBorderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: base.colorScheme.onPrimary,
        unselectedItemColor: base.colorScheme.onPrimary.withAlpha((0.82 * 255).round()),
      ),
    );
  }

  static ThemeData _applyAccessibilityTheme(ThemeData base) {
    final height = AppThemeController.lineHeight.value;
    final controlHighlight = AppThemeController.boldText.value;

    final textTheme = _applyLineHeightToTextTheme(base.textTheme, height);

    final primaryTextTheme = _applyLineHeightToTextTheme(base.primaryTextTheme, height);

    final accessibilityAdjusted = base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
    );

    return _applyControlHighlightTheme(accessibilityAdjusted, controlHighlight);
  }

  static ThemeData accessible() {
    // Accessible theme follows the selected daltonism variant while keeping the
    // content surfaces readable, with dark text on light cards and white text only
    // on dark accent surfaces such as app bars and action buttons.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.daltonismAccent,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    );

    return _applyAccessibilityTheme(
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surface,
        canvasColor: AppColors.surface,
        cardColor: AppColors.surface,
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
        ),
        dividerColor: AppColors.onSurface.withAlpha((0.38 * 255).round()),
        shadowColor: AppColors.onSurface.withAlpha((0.24 * 255).round()),
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
        textTheme: Typography.blackMountainView.copyWith(
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: AppColors.onSurface),
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.onPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.daltonismAccent,
          foregroundColor: AppColors.onPrimary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.onPrimary,
          unselectedItemColor: AppColors.onPrimary.withAlpha((0.7 * 255).round()),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface.withAlpha((0.12 * 255).round()),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.onSurface.withAlpha((0.70 * 255).round())),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(color: AppColors.onSurface, fontSize: 18),
          hintStyle: TextStyle(color: AppColors.onSurface.withAlpha((0.70 * 255).round()), fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.daltonismAccent,
            foregroundColor: AppColors.onPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppColors.daltonismAccent,
              width: 2,
            ),
            foregroundColor: AppColors.onSurface,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.onPrimary),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors._darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors._darkPrimary,
      secondary: AppColors._darkSecondary,
      surface: AppColors._darkSurface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
      error: AppColors.error,
    );

    return _applyAccessibilityTheme(
      ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors._darkSurface,
        canvasColor: AppColors._darkSurface,
        cardColor: AppColors._darkSecondary,
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors._darkSecondary,
        ),
        primaryColor: AppColors._darkPrimary,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors._darkPrimary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors._darkSecondary,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors._darkPrimary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withAlpha((0.72 * 255).round()),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors._darkSecondary.withAlpha((0.9 * 255).round()),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withAlpha((0.12 * 255).round()),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white.withAlpha((0.6 * 255).round())),
        ),
      ),
    );
  }

  static ThemeData theme(AppThemeMode mode) {
    if (mode == AppThemeMode.accessible) {
      return accessible();
    }
    if (mode == AppThemeMode.dark) {
      return dark();
    }
    return light();
  }
}


