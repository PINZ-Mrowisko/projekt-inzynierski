import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/platform_controller.dart';

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
    final pc = PlatformController.instance;

    return Obx(() {
      return pc.isMobile.value
          ? mobile
          : web;
    });
  }
}
