import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static const String _appId = '68717fb8-796d-4f6c-b11b-8e3fff493547';

  static Future<void> initialize() async {
    // Initialize OneSignal
    OneSignal.initialize(_appId);
    
    // Request permission for notifications (shows system dialog on first launch)
    await OneSignal.Notifications.requestPermission(true);

    // Listen for notification clicks — opens app to relevant section
    OneSignal.Notifications.addClickListener((event) {
      // You can navigate to a specific screen based on notification data here
    });
  }
}
