import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationService {

  static void initialize() {
    // for ios and web
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      print('A new onMessage event was published!');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }


  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken(vapidKey: "BFegerezgi_Uv2hezgtkqEDTzzertez-Xbt8OK8mJ4eteztVsdWDJQLkMg");
  }

}