import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/confirmation_dialog.dart';

void showPublishConfirmationDialog(VoidCallback onConfirmPublish) {
  Get.dialog(
    ConfirmationDialog(
      title: 'Czy na pewno chcesz opublikować grafik?',
      subtitle: 'Pracownicy zostaną powiadomieni o nowym grafiku.',
      confirmText: 'Opublikuj',
      cancelText: 'Anuluj',
      onConfirm: onConfirmPublish,
    ),
    barrierDismissible: false,
  );
}