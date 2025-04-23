import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/features/auth/controllers/login_controller.dart';
import 'package:the_basics/features/auth/screens/signup.dart';
import 'package:the_basics/utils/validators/validation.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, size: 50, color: Colors.blue),
              Form(
                key: controller.loginFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [

                      /// email
                      TextFormField(
                        controller: controller.email,
                        validator: (value) => MyValidator.validateEmail(value),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Iconsax.direct_right),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// hasło
                      Obx(
                        () => TextFormField(
                          expands: false,
                          decoration: InputDecoration(
                            labelText: "Hasło",
                            prefixIcon: Icon(Icons.password),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text("Zapamiętaj mnie"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  controller.emailAndPasswordSignIn();
                },
                child: const Text('Zaloguj się'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: const Text('Zarejestruj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
