import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import '../../../employees/controllers/user_controller.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Obx(() {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SideMenu(),
          ),
          Expanded(
            child: Container(
              color: AppColors.pageBackground,
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
    });
  }
}