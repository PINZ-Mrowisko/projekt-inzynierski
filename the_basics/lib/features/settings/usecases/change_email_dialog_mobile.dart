import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showChangeEmailDialogMobile(BuildContext context) {
  final newEmailController = TextEditingController();
  final errorMessage = RxString('');
  final userController = Get.find<UserController>();

  final errorText = Obx(() {
    if (errorMessage.value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        errorMessage.value,
        style: TextStyle(color: AppColors.warning, fontSize: 14),
      ),
    );
  });

  bool validateEmail(String email) {
    errorMessage.value = '';

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      errorMessage.value = 'Wpisz poprawny adres e-mail.';
      return false;
    }

    return true;
  }

  final fields = [
    DialogInputField(
      label: 'Nowy adres e-mail',
      controller: newEmailController,
    ),
    errorText,
  ];

  final actions = [
    DialogActionButton(
      label: "Zmień e-mail",
      onPressed: () async {
        final email = newEmailController.text.trim();

        if (!validateEmail(email)) {
          showCustomSnackbar(context, errorMessage.value);
          return;
        }

        try {
          // LOGIC TO BE IMPLEMENTED

          Get.back();
          showCustomSnackbar(context, "Link do zmiany adresu e-mail został wysłany na: $email");
        } catch (e) {
          showCustomSnackbar(context, "Błąd: ${e.toString()}");
        }
      },
    ),
  ];

  Get.dialog(
    Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 500,
        ),
        child: Transform.scale(
          scale: 0.85,
          child: SingleChildScrollView(
            child: CustomFormDialog(
              title: "Zmień adres e-mail",
              fields: fields,
              actions: actions,
              onClose: Get.back,
              width: 500,
              height: 350,
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
