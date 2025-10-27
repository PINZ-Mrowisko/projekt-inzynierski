import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/features/auth/controllers/login_controller.dart';
import 'package:the_basics/features/auth/screens/forget_pswd.dart';
import 'package:the_basics/features/auth/screens/signup.dart';
import 'package:the_basics/utils/validators/validation.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async{
        if (didPop) {controller.clearControllers();}
      },
      child: Obx(() {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2),
              ],
            ),


            child: Column(
                mainAxisSize: MainAxisSize.min,

              children: [
                    Form(
                    key: controller.loginFormKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                        SvgPicture.asset(
                          Get.isDarkMode 
                            ? 'assets/mrowisko_logo_blue_dark_mode.svg'
                            : 'assets/mrowisko_logo_blue.svg',
                          height: 48,
                        ),

                        const SizedBox(height: 40),

                        /// email
                        TextFormField(
                          controller: controller.email,
                          key: const Key("email_field"),
                          validator: (value) => MyValidator.validateEmail(value),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: const OutlineInputBorder(),
                          ),
                        ),

                          const SizedBox(height: 20),

                        /// hasło
                        Obx(
                          () => TextFormField(
                            expands: false,
                            key: const Key("password_field"),
                            decoration: InputDecoration(
                              labelText: "Hasło",
                              suffixIcon: IconButton(
                                onPressed:
                                    () =>
                                        controller.hidePswd.value =
                                            !controller.hidePswd.value,
                                icon: Icon(
                                  controller.hidePswd.value
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                ),
                              ),
                            ),
                            maxLines: 1,
                            controller: controller.pswd,
                            validator:
                                (value) => MyValidator.validateEmptyText(value),
                            obscureText: controller.hidePswd.value,
                          ),
                        ),

                          const SizedBox(height: 20),

                          /// funkcja remember me
                          Row(
                              children: [
                              Obx(
                                () => Checkbox(
                                  value: controller.rememberMe.value,
                                  onChanged:
                                      (value) =>
                                          controller.rememberMe.value =
                                              !controller.rememberMe.value,
                                ),
                              ),
                              Text("Pamiętaj mnie"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Get.to(() => ForgetPswd()),
                      child: Text('Zapomniałeś hasła?',
                        style: TextStyle(
                          color: AppColors.logo,
                              ),
                        overflow: TextOverflow.ellipsis,
                            ),
                          ),


                  const SizedBox(height: 10),

                  CustomButton(
                    onPressed: () {
                      controller.emailAndPasswordSignIn();
                    },
                    text: 'Zaloguj się',
                  ),

                  const SizedBox(height: 10),

                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Hide if no error
                }),

                const SizedBox(height: 10),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Nie masz konta? ", overflow: TextOverflow.ellipsis,),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text("Zarejestruj się",
                          style: TextStyle(
                            color: AppColors.logo),
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                    //const SizedBox(height: 10),
                  ],
                  ),
                  ],
              ),
          ),
          ),
        );
      }),
    );
  }
}
