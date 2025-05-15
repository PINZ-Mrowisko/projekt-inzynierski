import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/features/auth/screens/login_page.dart';

class ResetPswd extends StatelessWidget {
  const ResetPswd({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text("Email zostal wyslany!"),
              const SizedBox(height: 20,),
              const Text("Dostales super fajna wiadomosc na maila ktora mozesz kliknac zeby zresetowac swoje haslo"),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Get.offAll(() => LoginPage()), child: const Text("wracam do logowania")),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => ForgetPswdController.instance.resendPswdResetEmail(email), child: const Text("wyslij mi wiecej maili")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
