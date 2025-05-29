import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/screens/login_page.dart';
import 'package:the_basics/features/auth/controllers/signup_controller.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: controller.signUpFormKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/mrowisko_logo_blue.svg',
                          height: 48,
                        ),

                        const SizedBox(height: 40),

                        /// Imię
                        TextFormField(
                          controller: controller.firstName,
                          validator:
                              (value) => MyValidator.validateEmptyText(value),
                          decoration: InputDecoration(
                            labelText: 'Imię',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Nazwisko
                        TextFormField(
                          controller: controller.lastName,
                          validator:
                              (value) => MyValidator.validateEmptyText(value),
                          decoration: InputDecoration(
                            labelText: 'Nazwisko',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Email
                        TextFormField(
                          controller: controller.email,
                          validator:
                              (value) => MyValidator.validateEmail(value),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Hasło
                        Obx(
                          () => TextFormField(
                            controller: controller.pswd1,
                            validator:
                                (value) => MyValidator.validatePassword(value),
                            obscureText: controller.hidePswd1.value,
                            decoration: InputDecoration(
                              labelText: 'Hasło',
                              border: const OutlineInputBorder(),
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
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Powtórz Hasło
                        Obx(
                          () => TextFormField(
                            controller: controller.pswd2,
                            validator:
                                (value) => MyValidator.validateEmptyText(value),
                            obscureText: controller.hidePswd2.value,
                            decoration: InputDecoration(
                              labelText: 'Powtórz Hasło',
                              border: const OutlineInputBorder(),
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
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Nazwa oddziału
                        TextFormField(
                          controller: controller.marketName,
                          validator:
                              (value) => MyValidator.validateEmptyText(value),
                          decoration: InputDecoration(
                            labelText: 'Nazwa oddziału',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                CustomButton(
                  onPressed: () {
                    controller.signUp();
                  },
                  text: 'Stwórz konto',
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Masz już konto? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "Zaloguj się",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
