import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';

void showSaveConfirmationDialog(VoidCallback onConfirmSave) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy chcesz zatwierdzić zmiany?',
        confirmText: 'Zatwierdź',
        cancelText: 'Anuluj',
        onConfirm: onConfirmSave,
      ),
      barrierDismissible: false,
    );
  }