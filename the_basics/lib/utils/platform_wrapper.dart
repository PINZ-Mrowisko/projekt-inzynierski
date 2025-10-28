import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/platform_controller.dart';

// for readability - USE IN ROUTING!
class PlatformWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget web;

  const PlatformWrapper({
    super.key,
    required this.mobile,
    required this.web,
  });

  @override
  Widget build(BuildContext context) {
    final platformController = PlatformController.instance;

    return Obx(() {
      if (platformController.isMobile.value) {
        return mobile;
      } else {
        return web;
      }
    });
  }
}
