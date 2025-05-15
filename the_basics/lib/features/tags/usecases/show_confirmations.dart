import 'dart:ui';
import 'package:get/get.dart';
import '../../../utils/common_widgets/confirmation_dialog.dart';

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