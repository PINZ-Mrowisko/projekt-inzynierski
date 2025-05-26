import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/common_widgets/navbar.dart';
import '../controllers/verify_email_controller.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final verifyController = Get.put(VerifyEmailController());

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
                    const Text(
                      "Proszę potwierdź swój adres email.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Na twój adres email została wysłana wiadomość z linkiem.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     onPressed:
                    //         () =>
                    //             verifyController.checkEmailVerificationStatus(),
                    //     child: Text("Kontynuuj"),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 140, // Stała szerokość przycisku
                          child: CustomButton(
                            onPressed: () {
                              verifyController.sendEmailVerification();
                            },
                            text: 'Wyślij ponownie',
                          ),
                        ),

                        const SizedBox(width: 20), // Odstęp między przyciskami

                        SizedBox(
                          width: 140, // Stała szerokość przycisku
                          child: CustomButton(
                            onPressed: () {
                              verifyController.checkEmailVerificationStatus();
                            },
                            text: 'Kontynuuj',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
