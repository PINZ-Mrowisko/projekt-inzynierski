import 'dart:html' as html;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
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

  final RxBool systemPermissionGranted = false.obs;

  Future<void> initializeFCM() async {
    // this bit of code will help us register the need for a refresh after a bg notif
    // it listens to messages left by SW

    setupVisibilityRefresh();

    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        final data = event.data;
        if (data is! Map) return;

        switch (data['type']) {
          case 'FCM_EVENT':
            _handleBackgroundEvent(data['eventType']);
            break;

          case 'FCM_CLICK':
            _handleNotificationClick(data['eventType']);
            break;
        }
      });
    }

    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // if we get authorized then set up !
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _setupMessageHandlers();

        // set this up so our settings page shows correct values
        systemPermissionGranted.value = true;

        final String? vapidKey = kIsWeb ? 'BEZWrpAoThiHDnceouh-VGXXrJjwuISfnI2_NNCgvCwtzwCTuz4s9MIJMxyJcshKXzW5TFFV3_QUb0ZGZxhT9s0' : null;
        final token = await _firebaseMessaging.getToken(vapidKey: vapidKey);

        if (token != null) {
          currentToken.value = token;
          await _saveTokenToFirestore(token);
        }
      }
    } catch (e) {
      print('FCM Initialization Error: $e');
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
      final data = message.data;
      if (data.isEmpty) return;

      final type = data['type'];
      print(type);

      switch (type) {
        case 'NEW_SCHEDULE':
          Get.find<SchedulesController>().initialize();
          break;

        case 'LEAVE_STATUS_CHANGE':
          Get.find<LeaveController>().fetchLeaves();
          break;

          case 'NEW_LEAVE_REQUEST':
          Get.find<LeaveController>().fetchLeaves();
          break;

      }


    } else {
    }
  }

  void _handleBackgroundEvent(String eventType) {
    switch (eventType) {
      case 'LEAVE_STATUS_CHANGE':
        Get.find<LeaveController>().fetchLeaves();
        break;

      case 'NEW_SCHEDULE':
        Get.find<SchedulesController>().initialize();
        break;

      case 'NEW_LEAVE_REQUEST':
        Get.find<LeaveController>().fetchLeaves();
        break;
    }
    }

  void setupVisibilityRefresh() {
    if (!kIsWeb) return;

    html.document.onVisibilityChange.listen((_) {
      if (html.document.visibilityState == 'visible') {
        Get.find<LeaveController>().fetchLeaves();
      }
    });
  }

  void _handleNotificationClick(String eventType) {
    // odwiezazmy
    _handleBackgroundEvent(eventType);

    // nawigujemy do konkretnej strony
    switch (eventType) {
      case 'LEAVE_STATUS_CHANGE':
        Get.toNamed('/wnioski-urlopowe-pracownicy');
        break;

      case 'NEW_SCHEDULE':
        Get.toNamed('/grafik-ogolny-pracownicy');
        break;

      case 'NEW_LEAVE_REQUEST':
        Get.toNamed('/wnioski-urlopowe-kierownik');
        break;
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
        deviceInfo: '...',
        platform: '...',
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

  @override
  void onClose() {
    super.onClose();
  }


  /////////////////////////////////////////////////////////////////////////////////////////////////
  //                                actual notifs                                                //
  /////////////////////////////////////////////////////////////////////////////////////////////////

  // this notif is used after manager updates the status of a leave request
  Future<void> leaveStatusChangeNotification(String userId, String decision) async {
    final functions = FirebaseFunctions.instanceFor(region: 'europe-central2');

    try {
      final payload = <String, dynamic>{
        'marketId': _userController.employee.value.marketId,
        'userId': userId,
        'decision': decision, // we notify whether "accepted" or "denied"
      };

      final result = await functions.httpsCallable('sendLeaveStatusNotification').call(payload);

      //print("im sending");
      // print('Notification function result: ${result.data}');

    } on FirebaseFunctionsException catch (e) {
      //print('Function error: ${e.code} - ${e.message}');
    } catch (e) {
      //print('Unexpected error: $e');
    }
  }

  // need to modify this notif so it sends msg to all users in a schedule
  Future<void> testSendScheduleNotification() async {
    // we use the same function calling style as with the auth func previously
    final functions = FirebaseFunctions.instanceFor(region: 'europe-central2');

    try {
      final payload = <String, dynamic>{
        'marketId': _userController.employee.value.marketId,
        'scheduleName': 'Nowy Grafik',
      };

      final result = await functions.httpsCallable('sendScheduleNotification').call(payload);

      print('Notification function result: ${result.data}');
    } on FirebaseFunctionsException catch (e) {
      print('Function error: ${e.code} - ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}