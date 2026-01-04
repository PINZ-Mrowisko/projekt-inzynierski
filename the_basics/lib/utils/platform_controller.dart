import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:the_basics/utils/pwa_install_utils.dart';
import 'package:the_basics/utils/pwa_utils.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;


class PlatformController extends GetxController {
  static PlatformController get instance => Get.find();

  // we dont really check whether app is mobile or desktop, rather whether we want to display view for mobile or PC
  final RxBool isMobile = false.obs;
  final RxBool isDesktop = false.obs;

  final RxBool isStandalonePWA = false.obs;
  final RxBool canInstallPWA = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (kIsWeb) {
      _initWeb();
    } else {
      _initNative();
    }
  }

  void _initWeb() {
    // check whether we will be displaying PC or phone size
    _detectLayout();
    _detectPWAMode();
    _initPWAInstallListener();
  }

  void _initNative() {
    isMobile.value = true;
    isDesktop.value = false;
    isStandalonePWA.value = false;
    canInstallPWA.value = false;
  }

  void _detectLayout() {
    _updateLayout();

    WidgetsBinding.instance.platformDispatcher.onMetricsChanged = () {
      _updateLayout();
    };
  }


  void _updateLayout() {

    final double screenWidth = ui.window.physicalSize.width / ui.window.devicePixelRatio;
    const double mobileBreakpoint = 600.0;

    bool isPhone = screenWidth < mobileBreakpoint;

    //print('Screen width: $screenWidth, Detected as mobile: $isPhone');

    isMobile.value = isPhone;
    isDesktop.value = !isMobile.value;
  }



  void _detectPWAMode() {
    isStandalonePWA.value = isRunningAsPWA();
  }

  void _initPWAInstallListener() {
    canInstallPWA.value = canInstallPWA();

    if (kIsWeb) {
      _listenForInstallEvent();
    }
  }

  void _listenForInstallEvent() {

    html.window.addEventListener(
      'pwa-install-available',
          (_) => canInstallPWA.value = true,
    );
  }

  Future<void> installPWA() async {
    if (!kIsWeb || !canInstallPWA.value) return;

    final accepted = await triggerInstallPWA();
    canInstallPWA.value = false;

    if (accepted) {
      isStandalonePWA.value = true;
    }
  }
}
