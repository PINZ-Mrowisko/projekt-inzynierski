import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:get/get.dart';

class PlatformController extends GetxController {
  static PlatformController get instance => Get.find();

  final Rx<AppPlatform> currentPlatform = AppPlatform.web.obs;
  final RxBool isMobile = false.obs;
  final RxBool isTablet = false.obs;
  final RxBool isDesktop = false.obs;

  @override
  void onInit() {
    super.onInit();
    _detectPlatform();
  }

  void _detectPlatform() {
    if (kIsWeb) {
      currentPlatform.value = AppPlatform.web;
      isMobile.value = false;
      isDesktop.value = true;
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        currentPlatform.value = AppPlatform.mobile;
        isMobile.value = true;
        isDesktop.value = false;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        currentPlatform.value = AppPlatform.desktop;
        isMobile.value = false;
        isDesktop.value = true;
        print("iphone user detected shutting down the app");
      }
    }
  }

  // Helper methods
  bool get isWeb => currentPlatform.value == AppPlatform.web;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
}

enum AppPlatform {
  web,
  mobile,
  desktop,
}