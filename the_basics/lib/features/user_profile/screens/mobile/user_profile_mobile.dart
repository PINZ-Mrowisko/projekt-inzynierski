import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import '../../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/notification_snackbar.dart';

class UserProfileScreenMobile extends StatefulWidget {
  const UserProfileScreenMobile({super.key});

  @override
  State<UserProfileScreenMobile> createState() => _UserProfileScreenMobileState();
}

class _UserProfileScreenMobileState extends State<UserProfileScreenMobile> {
  late RxString shiftPreference;
  late UserController userController;
  final isLoading = false.obs;
  final readyToShow = false.obs;

  final RxInt _currentMenuIndex = 2.obs;

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
                      'Mój profil',
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
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: TextButton(
                      onPressed: () async {
                        if (user == null) return;
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
                      child: Text(
                        "Zapisz",
                        style: TextStyle(
                          color: AppColors.logo,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (!readyToShow.value || isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user == null) {
            return const Center(child: Text("Nie udało się załadować danych użytkownika"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 16),

                // one column with fields fore mobile readability
                _fieldBox("Imię", user.firstName),
                const SizedBox(height: 10),
                _fieldBox("Nazwisko", user.lastName),
                const SizedBox(height: 10),
                _fieldBox("Płeć", user.gender),
                const SizedBox(height: 10),
                _fieldBox(
                  "Tagi",
                  user.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                ),
                const SizedBox(height: 10),
                _fieldBox("E-mail", user.email),
                const SizedBox(height: 10),
                _fieldBox("Numer telefonu", user.phoneNumber),
                const SizedBox(height: 10),
                _fieldBox("Typ umowy", user.contractType),
                const SizedBox(height: 10),
                _fieldBox("Maksymalna ilość godzin tygodniowo", user.maxWeeklyHours.toString()),

                const SizedBox(height: 24),
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
              ],
            ),
          );
        }),
        bottomNavigationBar: MobileBottomMenu(currentIndex: _currentMenuIndex),
      );
    });
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
              color: AppColors.textColor1,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 56,
            child: DropdownButtonFormField<String>(
              value: shiftPreference.value.isEmpty ? null : shiftPreference.value,

              hint: Text(
                "Wybierz",
                style: TextStyle(
                  color: AppColors.textColor2,
                  fontSize: 16,
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Poranne",
                  child: Text(
                    "Poranne",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                DropdownMenuItem(
                  value: "Popołudniowe",
                  child: Text(
                    "Popołudniowe",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                DropdownMenuItem(
                  value: "Brak preferencji",
                  child: Text(
                    "Brak preferencji",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],

              onChanged: (v) => shiftPreference.value = v ?? "",

              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                hoverColor: AppColors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),

              style: TextStyle(
                fontSize: 16,
                height: 1.0,
                color: AppColors.textColor1,
              ),

              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),

              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(15),
              elevation: 4,
              menuMaxHeight: 300,
              itemHeight: 48,
            ),
          ),

          const SizedBox(height: 22),
        ],
      ),
    );
  }
}
