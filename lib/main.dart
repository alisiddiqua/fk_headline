import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/main_screen.dart';
import 'ui/splash_screen.dart';
import 'services/fcm_service.dart';

import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.fikrokhabar.app.channel.audio',
    androidNotificationChannelName: 'Islamiafkaar Audio Playback',
    androidNotificationOngoing: true,
  );
  
  // Initialize OneSignal push notifications
  await NotificationService.initialize();
  
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
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
