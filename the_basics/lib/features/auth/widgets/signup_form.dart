import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/features/auth/controllers/signup_controller.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

class MySignUpForm extends StatelessWidget {
  const MySignUpForm({super.key});

  /// TO DO
  // zrobić to ładnie wizualnie

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    return Form(
      key: controller.signUpFormKey,
      child: Column(
        children: [
          /// Imię
          TextFormField(
            expands: false,
            decoration: InputDecoration(
              labelText: "Imię",
              //prefixIcon: Icon(Icons.account_box),
            ),
            maxLines: 1,
            controller: controller.firstName,
            validator: (value) => MyValidator.validateEmptyText(value),
          ),
          const SizedBox(height: 20),

          /// Nazwisko
          TextFormField(
            expands: false,
            decoration: InputDecoration(
              labelText: "Nazwisko",
              //prefixIcon: Icon(Icons.account_box),
            ),
            maxLines: 1,
            controller: controller.lastName,
            validator: (value) => MyValidator.validateEmptyText(value),
          ),
          const SizedBox(height: 20),

          /// Email
          TextFormField(
            expands: false,
            decoration: InputDecoration(
              labelText: "Email",
              //prefixIcon: Icon(Icons.account_box),
            ),
            maxLines: 1,
            controller: controller.email,
            validator: (value) => MyValidator.validateEmail(value),
          ),
          const SizedBox(height: 20),

          /// Pswd1
          Obx(
            () => TextFormField(
              expands: false,
              decoration: InputDecoration(
                labelText: "Hasło",
                //prefixIcon: Icon(Icons.password),
                suffixIcon: IconButton(
                  onPressed:
                      () =>
                          controller.hidePswd1.value =
                              !controller.hidePswd1.value,
                  icon: Icon(
                    controller.hidePswd1.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
              ),
              maxLines: 1,
              controller: controller.pswd1,
              validator: (value) => MyValidator.validatePassword(value),
              obscureText: controller.hidePswd1.value,
            ),
          ),
          const SizedBox(height: 20),

          /// Pswd2
          Obx(
            () => TextFormField(
              expands: false,
              decoration: InputDecoration(
                labelText: "Powtórz Hasło",
                //prefixIcon: Icon(Icons.account_box),
                suffixIcon: IconButton(
                  onPressed:
                      () =>
                          controller.hidePswd2.value =
                              !controller.hidePswd2.value,
                  icon: Icon(
                    controller.hidePswd2.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
              ),
              maxLines: 1,
              controller: controller.pswd2,
              validator: (value) => MyValidator.validateEmptyText(value),
              obscureText: controller.hidePswd2.value,
            ),
          ),
          const SizedBox(height: 20),

          /// Nazwa oddziału
          TextFormField(
            expands: false,
            decoration: InputDecoration(
              labelText: "Nazwa oddziału",
              //prefixIcon: Icon(Icons.account_box),
            ),
            maxLines: 1,
            controller: controller.marketName,
            validator: (value) => MyValidator.validateEmptyText(value),
          ),
          const SizedBox(height: 20),

          /// here we can add some sort of RODO acceptance ?
          // checkbox

          CustomButton(
            onPressed: () {
              controller.signUp();
            },
            text: 'Stwórz konto',
          ),
        ],
      ),
    );
  }
}
