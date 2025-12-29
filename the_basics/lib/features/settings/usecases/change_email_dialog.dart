import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/form_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';


void showChangeEmailDialog(BuildContext context) {
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
          final _auth = FirebaseAuth.instance;
          // this method sends the email to the new email addrress + to the previous mail also in case of change
          await _auth.currentUser?.verifyBeforeUpdateEmail(email);

          Get.back();
          showCustomSnackbar(context, "Link do zmiany adresu e-mail został wysłany na: $email");
        } catch (e) {
          showCustomSnackbar(context, "Błąd: ${e.toString()}");
        }
      },
    ),
  ];

  Get.dialog(
    CustomFormDialog(
      title: "Zmień adres e-mail",
      fields: fields,
      actions: actions,
      onClose: Get.back,
      width: 500,
      height: 350,
    ),
    barrierDismissible: false,
  );
}
