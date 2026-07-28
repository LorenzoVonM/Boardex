import 'package:flutter/material.dart';
import 'screens/library_screen.dart';
import 'utils/theme_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.headerCoral,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.headerCoral,
          secondary: AppColors.brandTeal,
          tertiary: AppColors.brandBlue,
          surfaceTint: AppColors.headerCoral,
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.headerCoral,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFFFFF6F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Game Tracker App',
      theme: _buildTheme(Brightness.light),
      themeMode: ThemeMode.light,
      home: const LibraryScreen(),
    );
  }
}
