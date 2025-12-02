import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/settings/usecases/change_email_dialog.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import '../../auth/controllers/forget_pswd_controller.dart';
import '../../auth/models/user_model.dart';
import '../../employees/controllers/user_controller.dart';
import '../../../utils/common_widgets/side_menu.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final RxInt selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final user = userController.employee.value;

      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final isAdmin = user.role == "admin";

      final tabs = [
        "Powiadomienia",
        if (isAdmin) "Zarządzaj dostępem",
        "Hasło",
      ];

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: SideMenu(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ustawienia",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logo,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TABS
                    Obx(() {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < tabs.length; i++)
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => selectedTab.value = i,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: selectedTab.value == i
                                              ? AppColors.lightBlue
                                              : AppColors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      tabs[i],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: selectedTab.value == i
                                            ? AppColors.logolighter
                                            : AppColors.textColor2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // TAB CONTENT
                    Expanded(
                      child: Obx(() {
                        switch (selectedTab.value) {
                          case 0:
                            return _notificationsTab(user, userController);
                          case 1:
                            return isAdmin
                                ? _accessTab()
                                : _passwordTab(context, user);
                          case 2:
                            return _passwordTab(context, user);
                          default:
                            return Container();
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // NOTIFICATIONS TAB
  Widget _notificationsTab(UserModel user, UserController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsSwitch(
            title: 'Powiadom mnie o nowych grafikach',
            value: user.scheduleNotifs,
            onChanged: (val) => controller.updateSettings("scheduleNotifs", val),
          ),
      
          const SizedBox(height: 24),
      
          if (user.role == "admin")
            _settingsSwitch(
              title: 'Powiadom mnie o nowych wnioskach o nieobecność do zatwierdzenia',
              value: user.leaveNotifs,
              onChanged: (val) => controller.updateSettings("leaveNotifs", val),
            )
          else
            _settingsSwitch(
              title: 'Powiadom mnie o zmianach statusów moich wniosków',
              value: user.leaveNotifs,
              onChanged: (val) => controller.updateSettings("leaveNotifs", val),
            ),
        ],
      ),
    );
  }

  // ACCESS MANAGEMENT TAB
  Widget _accessTab() {
    final userController = Get.find<UserController>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "W tym panelu masz możliwość ponownie wysłać wiadomość zapraszającą do pracowników, którzy jeszcze nie zarejestrowali się w aplikacji.\n"
            "Pamiętaj, że do danego użytkownika możesz wysłać 1 wiadomość co 5 minut.",
            style: TextStyle(fontSize: 16, color: AppColors.textColor2),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: Obx(() {
              final users = userController.allEmployees
                  .where((u) => u.hasLoggedIn == false)
                  .toList();

              if (users.isEmpty) {
                return const Center(
                  child: Text(
                    "Wszyscy użytkownicy dokonali rejestracji.",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return GenericList<UserModel>(
                items: users,
                itemBuilder: (context, user) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      "${user.firstName} ${user.lastName}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor1,
                      ),
                    ),
                    subtitle: Text(
                      "Nie zarejestrował(a) się jeszcze w aplikacji",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor2,
                      ),
                    ),
                    trailing: CustomButton(
                      text: "Wyślij",
                      icon: Icons.email_outlined,
                      onPressed: () => _sendResetEmail(context, user),
                      backgroundColor: AppColors.blue,
                      textColor: AppColors.textColor2,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // PASSWORD MANAGEMENT TAB
  Widget _passwordTab(BuildContext context, UserModel employee) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsButton(
            title: "Zresetuj swoje hasło",
            buttonText: "Resetuj hasło",
            icon: Icons.key_outlined,
            onPressed: () {
              // BACKEND please verify
              _sendResetEmail(context, employee);
            },
          ),

          const SizedBox(height: 24),

          _settingsButton(
            title: "Zmień adres e-mail",
            buttonText: "Zmień e-mail",
            icon: Icons.email_outlined,
            onPressed: () {
              // IMPLEMENT THERE
              showChangeEmailDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // HELPER WIDGETS
  Widget _settingsSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.logo,
          ),
        ],
      ),
    );
  }

    Widget _settingsButton({
      required String title,
      required String buttonText,
      required VoidCallback onPressed,
      IconData? icon,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textColor2,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: buttonText,
              icon: icon,
              onPressed: onPressed,
              backgroundColor: AppColors.blue,
              textColor: AppColors.textColor2,
              width: 150,
              height: 42,
            ),
          ],
        ),
      );
    }

  void _sendResetEmail(BuildContext context, UserModel employee) async {
    try {
      Get.put(ForgetPswdController());
      await ForgetPswdController.instance.resendPswdResetEmail(employee.email);
      showCustomSnackbar(context, "Link do resetowania hasła został wysłany.");
    } catch (e) {
      showCustomSnackbar(context, "Nie udało się wysłać e-maila: ${e.toString()}");
    }
  }

}
