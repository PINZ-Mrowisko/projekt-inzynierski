import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';

void showPublishConfirmationDialogMobile(VoidCallback onConfirmPublish) {
  Get.dialog(
    Transform.scale(
      scale: 0.85,
      child: ConfirmationDialog(
      title: 'Czy na pewno chcesz opublikować grafik?',
      subtitle: 'Pracownicy zostaną powiadomieni o nowym grafiku.',
      confirmText: 'Opublikuj',
      cancelText: 'Anuluj',
      onConfirm: onConfirmPublish,
      ),
    ),
    barrierDismissible: false,
  );
}