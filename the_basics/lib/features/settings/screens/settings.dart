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
      final user = userController.employee.value;
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(title: const Text('Ustawienia')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification settings section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ustawienia powiadomień',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildSwitchTile(
                    title: 'Powiadom mnie o nowych grafikach',
                    value: user.scheduleNotifs,
                    onChanged: (val) {
                      userController.updateSettings("scheduleNotifs", val);
                    },
                  ),

                  if (user.role == "admin")
                  // dla adminow wyswietlamy inny tekst ale w sumie kontroluje to tą samą funkcjonalność
                    _buildSwitchTile(
                      title: 'Powiadom mnie o nowych wnioskach o nieobecność wymagających zatwierdzenia',
                      value: user.leaveNotifs,
                      onChanged: (val) {
                        userController.updateSettings("leaveNotifs", val);
                      },
                    )
                  else
                    _buildSwitchTile(
                      title: 'Powiadom mnie o zmianach statusu moich wniosków',
                      value: user.leaveNotifs,
                      onChanged: (val) {
                        userController.updateSettings("leaveNotifs", val);
                      },
                    ),

                ],
              ),
            ),
            const Divider(),
            // Users who haven’t logged in section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Użytkownicy, którzy jeszcze nie zalogowali się do aplikacji:',
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
                        icon: const Icon(Icons.lock_reset),
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
    try {
      Get.put(ForgetPswdController());
      await ForgetPswdController.instance.resendPswdResetEmail(employee.email);
      Get.snackbar("Wysłano", "Link do resetowania hasła został wysłany.");
    } catch (e) {
      Get.snackbar("Błąd", "Nie udało się wysłać e-maila: ${e.toString()}");
    }
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.lightBlue,
    );
  }
}