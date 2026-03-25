// lib/services/fcm_service.dart

class FCMService {
  static Future<void> initialize() async {
    // NOTE: Activating Firebase requires google-services.json from your Firebase Console.
    // Once you have it, run `flutterfire configure` and uncomment these:
    
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    // await messaging.requestPermission();
    // 
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // 
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground: ${message.data}');
    // });
  }

  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print("Handling a background message: ${message.messageId}");
  // }
}
