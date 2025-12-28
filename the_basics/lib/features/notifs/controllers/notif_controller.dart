import 'dart:io';
import 'dart:js' as js;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import '../../../data/repositiories/other/notifs/token_repo.dart';
import '../models/token_model.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final TokenRepo _tokenRepo = Get.find();
  final UserController _userController = Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final RxString currentToken = ''.obs;
  final RxBool isTokenSaved = false.obs;
  final RxString errorMessage = ''.obs;

  // we will use this to handle local notifications in the app (when its in the foreground, so user active using)
  // nvm - local notifs work only for android apparently?
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final RxBool systemPermissionGranted = false.obs;

  Future<void> initializeFCM() async {
    print("here!!!!!!!!!!!!!");

    try {
      if (kIsWeb) {
        //await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);

        NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('Notification permission: ${settings.authorizationStatus}');

        //await _initializeFCMForWeb();
      } else {
        await requestPermissions();
        await _initializeLocalNotifications();
      }

      await checkSystemPermission();

      final String? vapidKey = kIsWeb ? 'BEZWrpAoThiHDnceouh-VGXXrJjwuISfnI2_NNCgvCwtzwCTuz4s9MIJMxyJcshKXzW5TFFV3_QUb0ZGZxhT9s0' : null;
      final token = await _firebaseMessaging.getToken(vapidKey: vapidKey);

      print("hjere is my token");
      print(token);

      if (token != null) {
        currentToken.value = token;
        await _saveTokenToFirestore(token);
      }



      _setupTokenRefreshListener();
      _setupMessageHandlers();

    } catch (e) {
      errorMessage.value = 'Błąd inicjalizacji FCM: ${e.toString()}';
      print('FCM Initialization Error: $e');
    }
  }

  Future<void> _initializeFCMForWeb() async {
    try {
      if (kIsWeb) {
        final token = await _firebaseMessaging.getToken(
          vapidKey: 'BEZWrpAoThiHDnceouh-VGXXrJjwuISfnI2_NNCgvCwtzwCTuz4s9MIJMxyJcshKXzW5TFFV3_QUb0ZGZxhT9s0',
        );
        print('Web token initialized: $token');
      }
    } catch (e) {
      print('Web FCM initialization error: $e');
    }
  }

  Future<void> requestWebPermission() async {
    try {
      if (!kIsWeb) return;

      final jsPermission = js.context['Notification']['permission'];
      if (jsPermission == 'default') {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await checkSystemPermission();
    } catch (e) {
      print('Web permission error: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
     // print('Background message opened: ${message.notification?.title}');
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kIsWeb) {
    } else {
      _showLocalNotification(message);
    }
  }


  Future<void> checkSystemPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    systemPermissionGranted.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = _userController.employee.value;
      if (currentUser.id.isEmpty) return;

      final tokenModel = TokenModel(
        userId: currentUser.id,
        token: token,
        deviceInfo: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        platform: Platform.operatingSystem.toString(),
        appVersion: '1.0.0',
        insertedAt: DateTime.now(),
        lastActive: DateTime.now(),
        isActive: true,
      );


      await _tokenRepo.saveToken(tokenModel, _userController.employee.value.marketId);
      isTokenSaved.value = true;

      //print('FCM Token saved for user: ${currentUser.id}');
    } catch (e) {
      errorMessage.value = 'Błąd zapisu tokenu: ${e.toString()}';
      //print('Token save error: $e');
    }
  }

  /// Listen for token refresh (app reinstall, data clearance)
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      //print('FCM Token refreshed: $newToken');
      currentToken.value = newToken;
      await _saveTokenToFirestore(newToken);
    });
  }

  Future<void> testSendScheduleNotification() async {
    // we use the same function calling style as with the auth func previously
    final functions = FirebaseFunctions.instanceFor(region: 'europe-central2');

    try {
      final payload = <String, dynamic>{
        'marketId': _userController.employee.value.marketId,
        'scheduleName': 'Grafik Listopad',
      };

      final result = await functions.httpsCallable('sendScheduleNotification').call(payload);

      print('Notification function result: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print('Function error: ${e.code} - ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> leaveStatusChangeNotification(String userId, String decision) async {
    final functions = FirebaseFunctions.instanceFor(region: 'europe-central2');

    try {
      final payload = <String, dynamic>{
        'marketId': _userController.employee.value.marketId,
        'userId': userId,
        'decision': decision, // we notify whether "accepted" or "denied"
      };

      final result = await functions.httpsCallable('sendLeaveStatusNotification').call(payload);
      print("im sending");
      print('Notification function result: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print('Function error: ${e.code} - ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  /// deactivate token when user logs out
  Future<void> deactivateCurrentToken() async {
    try {
      final currentUser = _userController.employee.value;
      if (currentUser.id.isNotEmpty && currentToken.value.isNotEmpty) {
        await _tokenRepo.deactivateToken(currentUser.id, currentToken.value, currentUser.marketId);
        isTokenSaved.value = false;
        //print('Token deactivated for user: ${currentUser.id}');
      }
    } catch (e) {
      errorMessage.value = 'Błąd deaktywacji tokenu: ${e.toString()}';
    }
  }

  /// used when user logs in
  Future<void> reactivateCurrentToken() async {
    try {
      final currentUser = _userController.employee.value;
      if (currentUser.id.isNotEmpty && currentToken.value.isNotEmpty) {
        await _tokenRepo.updateTokenActivity(currentUser.id, currentToken.value, true, currentUser.marketId);
        isTokenSaved.value = true;
        //print('Token reactivated for user: ${currentUser.id}');
      }
    } catch (e) {
      errorMessage.value = 'Błąd reaktywacji tokenu: ${e.toString()}';
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      systemPermissionGranted.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      print('User granted permission: ${settings.authorizationStatus}');
    } on PlatformException catch (e) {
      print('Permission error: ${e.message}');
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'App notifications when foregrounded',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}