import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/side_menu.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late RxString shiftPreference;
  late UserController userController;
  final isLoading = false.obs;
  final readyToShow = false.obs;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    shiftPreference = RxString('');

    // making sure to fetch newest user data (in case admin edits themselves and wants to check changes)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      try {
        await userController.fetchCurrentUserRecord();
        await Future.delayed(const Duration(milliseconds: 50)); // tiny delay to avoid artifacts when fetching newest data
        if (userController.employee.value != null) {
          shiftPreference.value = userController.employee.value!.shiftPreference;
        readyToShow.value = true;
        }
      } finally {
        isLoading.value = false;
      }
    });

    ever(userController.employee, (user) {
      if (user != null) {
        shiftPreference.value = user.shiftPreference;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = userController.employee.value;
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Mój profil",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (!readyToShow.value || isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (user == null) {
                          return const Center(
                            child: Text("Nie udało się załadować danych użytkownika"),
                          );
                        }
                        
                        shiftPreference.value = user.shiftPreference;
                        
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Dane użytkownika",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.logolighter,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildProfileGrid(user),
                              const SizedBox(height: 32),
                              Text(
                                "Preferencje",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.logolighter,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _preferredShiftField(),
                              const SizedBox(height: 32),
                              Align(
                                alignment: Alignment.centerRight,
                                child: CustomButton(
                                  text: "Zapisz",
                                  backgroundColor: AppColors.blue,
                                  textColor: AppColors.textColor2,
                                  icon: Icons.save,
                                  onPressed: () async {
                                    try {
                                      isLoading.value = true;
                                      final updatedUser = user.copyWith(
                                        shiftPreference: shiftPreference.value,
                                      );
                                      await userController.updateEmployee(updatedUser);
                                      showCustomSnackbar(context, "Pomyślnie zaktualizowano profil.");
                                      await userController.fetchCurrentUserRecord();
                                    } catch (e) {
                                      showCustomSnackbar(context, "Nie udało się zapisać zmian: $e");
                                    } finally {
                                      isLoading.value = false;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
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

  Widget _buildProfileGrid(dynamic user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _fieldBox("Imię", user.firstName)),
            const SizedBox(width: 16),
            Expanded(child: _fieldBox("Nazwisko", user.lastName)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              //TODO: display actual gender when its added to user model
              child: _fieldBox("Płeć", "-"),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _fieldBox(
                "Tagi",
                user.tags.toString().replaceAll("[", "").replaceAll("]", ""),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _fieldBox("E-mail", user.email)),
            const SizedBox(width: 16),
            Expanded(child: _fieldBox("Numer telefonu", user.phoneNumber)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _fieldBox("Typ umowy", user.contractType)),
            const SizedBox(width: 16),
            Expanded(child: _fieldBox("Maksymalna ilość godzin tygodniowo", user.maxWeeklyHours.toString())),
          ],
        ),
      ],
    );
  }

  // uneditable field box
  Widget _fieldBox(String label, String value, {bool editable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: editable ? AppColors.textColor2 : AppColors.textColor2.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: editable ? AppColors.white : AppColors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: editable ? AppColors.textColor2 : AppColors.textColor2.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              fontSize: 14,
              color: editable ? AppColors.black : AppColors.black.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // editable preferred shift field
  Widget _preferredShiftField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Preferencje zmian",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColor2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.textColor2, width: 1),
            ),
            child: DropdownButton<String>(
              value: shiftPreference.value.isEmpty ? null : shiftPreference.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: "Poranne", child: Text("Poranne")),
                DropdownMenuItem(value: "Popołudniowe", child: Text("Popołudniowe")),
                DropdownMenuItem(value: "Brak preferencji", child: Text("Brak preferencji")),
              ],
              onChanged: (v) => shiftPreference.value = v ?? "",
            ),
          ),
        ],
      ),
    );
  }
}