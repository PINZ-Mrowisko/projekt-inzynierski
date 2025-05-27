/// THIS IS THE OLD METHOD
/// TO DO: move current implementation from employee_managemnt to here
///
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';

void showConfirmDeleteDialog(String employeeId, String marketId) {
  final userController = Get.find<UserController>();

  Get.dialog(
    AlertDialog(
      title: const Text('Potwierdź usunięcie pracownika'),
      content: const Text(
        'Czy na pewno chcesz usunąć tego pracownika? Tej akcji (obecnie) nie można cofnąć.',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Anuluj')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            try {

              // show loading indicator
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              // delete user
              final success = await userController.deleteEmployee(employeeId, marketId);

              if (success) {
                // Close all dialogs
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop(); // Loading
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop(); // Confirmation
              } else {
                throw Exception('Nie udało sie usunąć pracownika');
              }
            } catch (e) {
              // Close loading dialog if error occurs
              if (Get.isDialogOpen ?? false) {
                Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
              }

              // Show error message
              Get.snackbar(
                'Błąd',
                'Nie udało się usunąć pracownika: ${e.toString()}',
                snackPosition: SnackPosition.BOTTOM,
              );
            }

            //await userController.deleteEmployee(employeeId);
            //Get.back();
          },
          child: const Text('Usuń'),
        ),
      ],
    ),
  );
}
