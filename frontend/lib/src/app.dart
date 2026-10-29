
import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/welcome_page.dart';
import 'pages/tutoriais_page.dart';

// Classe AppVivaFit representa um componente ou widget da interface.
class AppVivaFit extends StatefulWidget {
  const AppVivaFit({super.key});

  @override
  State<AppVivaFit> createState() => _AppVivaFitState();
}

// Classe _AppVivaFitState representa um componente ou widget da interface.
class _AppVivaFitState extends State<AppVivaFit> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, mode, child) {
        return ValueListenableBuilder<DaltonismVariant>(
          valueListenable: AppThemeController.daltonismVariant,
          builder: (context, variant, _) {
            return ValueListenableBuilder<double>(
              valueListenable: AppThemeController.fontScale,
              builder: (context, fontScale, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: AppThemeController.lineHeight,
                  builder: (context, lineHeight, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: AppThemeController.boldText,
                      builder: (context, _, child) {
                        final baseTheme = AppTheme.theme(mode);

                        return MaterialApp(
                          title: 'AppVivaFit',
                          theme: baseTheme,
                          themeAnimationDuration: Duration.zero,
                          builder: (context, child) {
                            final mediaQuery = MediaQuery.of(context);
                            final baseTextStyle = TextStyle(height: lineHeight);

                            return MediaQuery(
                              data: mediaQuery.copyWith(
                                textScaler: TextScaler.linear(fontScale),
                              ),
                              child: Theme(
                                data: baseTheme,
                                child: DefaultTextStyle(
                                  style: baseTextStyle,
                                  child: child ?? const SizedBox.shrink(),
                                ),
                              ),
                            );
                          },
                          home: const WelcomePage(),
                          routes: {'/tutoriais': (context) => const TutoriaisPage()},
                          debugShowCheckedModeBanner: false,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}


