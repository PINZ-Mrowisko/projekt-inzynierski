import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final RxBool systemPermissionGranted = false.obs;

  Future<void> checkSystemPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();

    systemPermissionGranted.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// initialize FCM during app startup
  Future<void> initializeFCM() async {
    try {
      // Request permissions from user ; should be one time thing
      await requestPermissions();

      await checkSystemPermission();

      // allows for foreground notifs
      // important that this stays above message handlers
      _initializeLocalNotifications();

      // Get current FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        currentToken.value = token;
        print(token);
        await _saveTokenToFirestore(token);
      }

      // we setup token refresh listener
      _setupTokenRefreshListener();

      // also setup message handlers
      _setupMessageHandlers();

    } catch (e) {
      errorMessage.value = 'Błąd inicjalizacji FCM: ${e.toString()}';
      print('FCM Initialization Error: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);
  }

  /// Request notification permissions
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

  /// Save token to Firestore for current user
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = _userController.employee.value;
      if (currentUser.id.isEmpty) {
        print('No user logged in, skipping token save');
        return;
      }

      final tokenModel = TokenModel(
        userId: currentUser.id,
        token: token,
        deviceInfo: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        platform: Platform.operatingSystem.toString(),
        appVersion: '1.0.0', // You can get this from package_info
        insertedAt: DateTime.now(),
        lastActive: DateTime.now(),
        isActive: true,
      );


      await _tokenRepo.saveToken(tokenModel, _userController.employee.value.marketId);
      isTokenSaved.value = true;

      print('FCM Token saved for user: ${currentUser.id}');
    } catch (e) {
      errorMessage.value = 'Błąd zapisu tokenu: ${e.toString()}';
      print('Token save error: $e');
    }
  }

  /// Listen for token refresh (app reinstall, data clearance)
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      currentToken.value = newToken;
      await _saveTokenToFirestore(newToken);
    });
  }

  /// message handlers for different states
  void _setupMessageHandlers() {

    // we need to handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Background message opened: ${message.notification?.title}');
    });

    // app is terminated and opened via notification
    //_handleTerminatedMessage();
  }

  /// foreground message : user is in the app when he gets notification
  void _handleForegroundMessage(RemoteMessage message) {
    //print('Foreground message: ${message.notification?.title}');
    _showLocalNotification(message);
  }

  /// Show local notification using flutter_local_notifications
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


  // this will later need to be changed into notifyin users of new schedule
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
      print(' Unexpected error: $e');
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
        print('Token deactivated for user: ${currentUser.id}');
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
        print('Token reactivated for user: ${currentUser.id}');
      }
    } catch (e) {
      errorMessage.value = 'Błąd reaktywacji tokenu: ${e.toString()}';
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}