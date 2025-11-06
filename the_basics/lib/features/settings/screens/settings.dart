import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../auth/controllers/forget_pswd_controller.dart';
import '../../auth/models/user_model.dart';
import '../../employees/controllers/user_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Obx(() {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Users who haven’t logged in:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Obx(() {
              final users = userController.allEmployees
                  .where((user) => user.hasLoggedIn == false)
                  .toList();

              if (users.isEmpty) {
                return const Center(child: Text('All users have logged in! 🎉'));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: Icon(Icons.lock_reset),
                      onPressed: () => _sendResetEmail(user),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
    });
  }

  void _sendResetEmail(UserModel employee) async {
    //final now = DateTime.now();
    try {
      Get.put(ForgetPswdController());
      await ForgetPswdController.instance.resendPswdResetEmail(employee.email);
      Get.snackbar("Wysłano", "Link do resetowania hasła został wysłany.");
    } catch (e) {
      Get.snackbar("Błąd", "Nie udało się wysłać e-maila: ${e.toString()}");
    }
  }
}