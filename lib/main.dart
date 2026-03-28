import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/main_screen.dart';
import 'ui/splash_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize OneSignal push notifications
  await NotificationService.initialize();

  // Initialize AudioService for background playback
  final audioService = AudioServiceWrapper();
  await audioService.init();
  
  runApp(ProviderScope(
    overrides: [
      audioServiceProvider.overrideWithValue(audioService),
    ],
    child: const FKHeadlineApp(),
  ));
}

class FKHeadlineApp extends StatelessWidget {
  const FKHeadlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FK Headline',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
