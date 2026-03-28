import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/main_screen.dart';
import 'ui/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/fcm_service.dart';
import 'services/audio_service.dart';
import 'providers/api_provider.dart';

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

class FKHeadlineApp extends ConsumerWidget {
  const FKHeadlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final isUrdu = language == AppLanguage.urdu;

    return MaterialApp(
      title: 'FK Headline',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: isUrdu ? const Locale('ur', 'PK') : const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ur', 'PK'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
