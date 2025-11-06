import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';

void showLeaveConfirmationDialog(VoidCallback onConfirmLeave) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz wyjść bez zapisania zmian?',
        confirmText: 'Tak',
        cancelText: 'Anuluj',
        onConfirm: onConfirmLeave,
      ),
      barrierDismissible: false,
    );
  }