import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/utils/validators/validation.dart';

class ForgetPswd extends StatelessWidget {
  const ForgetPswd({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPswdController()); //create the instance here

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Zapomniałeś hasła?"),
            const SizedBox(height: 20,),
            const Text("Wpisz adres email to ci zresetujemy"),
            const SizedBox(height: 20,),

            /// email form
            Form(
              key: controller.forgetPswdFormKey,
              child: TextFormField(
                controller: controller.email,
                validator: (value) => MyValidator.validateEmail(value),
                decoration: const InputDecoration(labelText: "email", prefixIcon: Icon(Iconsax.direct_right))
              ),
            ),
            const SizedBox(height: 10,),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => controller.sendPswdResetEmail(), child: Text("Poprosze maila")),
            )
          ],
        ),
      ),
    );
  }
}
