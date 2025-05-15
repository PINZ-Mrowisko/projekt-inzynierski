import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import '../../../employees/controllers/user_controller.dart';

class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const SideMenu(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: Obx(() => Text(
                  controller.employee.value.firstName,
                  style: const TextStyle(fontSize: 24),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
