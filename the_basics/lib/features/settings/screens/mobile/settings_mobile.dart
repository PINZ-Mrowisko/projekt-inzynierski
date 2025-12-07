import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/controllers/forget_pswd_controller.dart';
import 'package:the_basics/features/notifs/controllers/notif_controller.dart';
import 'package:the_basics/features/settings/usecases/change_email_dialog_mobile.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/features/settings/usecases/change_email_dialog.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';

class SettingsScreenMobile extends StatelessWidget {
  SettingsScreenMobile({super.key});

  final RxInt selectedTab = 0.obs;
  final RxInt currentMenuIndex = 2.obs;

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final notifController = Get.find<NotificationController>();

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
        if (isAdmin) "Dostępy",
        "Hasło",
      ];

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
            color: AppColors.pageBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Ustawienia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // TABS
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedTab.value = i,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            child: Center(
                              child: Text(
                                tabs[i],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selectedTab.value == i
                                      ? AppColors.logolighter
                                      : AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // TAB CONTENT
            Expanded(
              child: Obx(() {
                switch (selectedTab.value) {
                  case 0:
                    return _notificationsTab(context, user, userController, notifController);

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
            )
          ],
        ),
        bottomNavigationBar: MobileBottomMenu(currentIndex: currentMenuIndex),
      );
    });
  }

  // NOTIFICATIONS TAB
  Widget _notificationsTab(BuildContext context, UserModel user, UserController userController, NotificationController notifController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingsSwitch(
            title: 'Powiadom mnie o nowych grafikach',
            value: user.scheduleNotifs && notifController.systemPermissionGranted.value,
            onChanged: (val) async {

              if (val == true && !notifController.systemPermissionGranted.value) {
                await notifController.requestPermissions();
                await notifController.checkSystemPermission();

                if (!notifController.systemPermissionGranted.value) {
                  showCustomSnackbar(context, "Musisz włączyć powiadomienia w ustawieniach telefonu.");
                  return;
                }
              }

              userController.updateSettings("scheduleNotifs", val);
            },
          ),
      
          const SizedBox(height: 24),
      
          _settingsSwitch(
          title: user.role == "admin"
              ? 'Powiadom mnie o nowych wnioskach do zatwierdzenia'
              : 'Powiadom mnie o zmianach statusów moich wniosków',
          value: user.leaveNotifs && notifController.systemPermissionGranted.value,
          onChanged: (val) async {

              if (val == true && !notifController.systemPermissionGranted.value) {
                await notifController.requestPermissions();
                await notifController.checkSystemPermission();

                if (!notifController.systemPermissionGranted.value) {
                  showCustomSnackbar(context, "Musisz włączyć powiadomienia w ustawieniach telefonu.");
                  return;
                }
              }

              userController.updateSettings("leaveNotifs", val);
            },
          ),
        ],
      ),
    );
  }

  // ACCESS MANAGEMENT TAB
  Widget _accessTab() {
    final userController = Get.find<UserController>();

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "W tym panelu masz możliwość ponownie wysłać wiadomość zapraszającą do pracowników, którzy jeszcze nie zarejestrowali się w aplikacji.\n"
            "Pamiętaj, że do danego użytkownika możesz wysłać 1 wiadomość co 5 minut.",
            style: TextStyle(fontSize: 16, color: AppColors.textColor2),
          ),

          const SizedBox(height: 16),

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
              showChangeEmailDialogMobile(context);
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
