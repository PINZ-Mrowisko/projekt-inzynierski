import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';

void showConfirmDeleteDialog(String employeeId) {
  final userController = Get.find<UserController>();

  Get.dialog(AlertDialog(
    title: const Text('Potwierdź usunięcie pracownika'),
    content: const Text('Czy na pewno chcesz usunąć tego pracownika? Tej akcji (obecnie) nie można cofnąć.'),
    actions: [
      TextButton(onPressed: Get.back, child: const Text('Anuluj')),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await userController.deleteEmployee(employeeId);
          Get.back();
        },
        child: const Text('Usuń'),
      ),
    ],
  ));
}
