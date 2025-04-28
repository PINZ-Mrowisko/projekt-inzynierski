import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/widgets/logged_navbar.dart';

import '../../controllers/user_controller.dart';

class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          LoggedNavBar(),
          Expanded(
            child: Center(
              child: Obx( () {
                return Text(
                    controller.employee.value.firstName
                );
              }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
