import 'dart:ui';
import 'package:get/get.dart';
import '../../../utils/common_widgets/confirmation_dialog.dart';

void showExitConfirmationDialog(VoidCallback onConfirmExit) {
  Get.dialog(
    ConfirmationDialog(
      title: 'Czy na pewno chcesz wyjść?',
      subtitle: 'Twój progres nie zostanie zapisany.',
      confirmText: 'Wyjdź',
      cancelText: 'Anuluj',
      onConfirm: onConfirmExit,
    ),
    barrierDismissible: false,
  );
}

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