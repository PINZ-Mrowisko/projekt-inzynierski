import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import '../../../employees/controllers/user_controller.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

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
            child: SideMenu(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: Obx(() => Text(
                  '${controller.employee.value.firstName}\nPlaceholder Page',
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