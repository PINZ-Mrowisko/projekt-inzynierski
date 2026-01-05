import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';

void showLeaveConfirmationDialogMobile(VoidCallback onConfirmLeave) {
  Get.dialog(
    Transform.scale(
      scale: 0.85,
      child: ConfirmationDialog(
        title: 'Czy na pewno chcesz wyjść bez zapisania zmian?',
        confirmText: 'Tak',
        cancelText: 'Anuluj',
        onConfirm: onConfirmLeave,
      ),
    ),
    barrierDismissible: false,
  );
}