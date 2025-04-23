import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../schedules/widgets/navbar.dart';
import '../controllers/verify_email_controller.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final verify_controller = Get.put(VerifyEmailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NavBar(),
          // maybe add a back button to navigate back to homepage
          // wtedy nalezy uzyc AuthRepo.instance.logout()
          Expanded(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // maybe but some mail img or icon or stuff
                    const SizedBox(height: 20),
                    const Text("Proszę potwierdż swój adres email.", textAlign: TextAlign.center,),
                    const SizedBox(height: 20),
                    const Text("Na twój adres email została wysłana wiadomość z linkiem.", textAlign: TextAlign.center),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => verify_controller.checkEmailVerificationStatus(),
                          child: Text("Kontynuuj")
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// resend email
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => verify_controller.sendEmailVerification(),
                          child: Text("Wyślij mail ponownie")
                      ),
                    ),
                  ]
                ),
              )
              ),
            ),
        ],
      ),
    );
  }
}
