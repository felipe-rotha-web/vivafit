import 'package:appvivafit/src/app.dart';
import 'package:appvivafit/src/theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.loadFromPreferences();
  runApp(const AppVivaFit());
}