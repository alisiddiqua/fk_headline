import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/main_screen.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: FKHeadlineApp()));
}

class FKHeadlineApp extends StatelessWidget {
  const FKHeadlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FK Headline',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto toggle based on system
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
