import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import 'package:the_basics/utils/common_widgets/side_menu.dart';

class EmployeeMorePageMobile extends StatelessWidget {
  EmployeeMorePageMobile({super.key});

  final userController = Get.find<UserController>();
  final sideMenuController = Get.find<SideMenuController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            'Więcej',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildMenuRow(Icons.sunny, 'Wnioski urlopowe', () => _navigateTo('/wnioski-urlopowe-pracownicy')),
                Divider(height: 1, color: AppColors.divider),
                _buildMenuRow(Icons.person, 'Twój profil', () => _navigateTo('/twoj-profil')),

                const SizedBox(height: 30),
                _buildSwitchRow(
                      icon: Icons.dark_mode,
                      text: 'Tryb ciemny',
                      value: sideMenuController.isDarkMode.value,
                      onChanged: (val) => sideMenuController.setDarkMode(val),
                    ),
                Divider(height: 1, color: AppColors.divider),
                _buildMenuRow(Icons.settings, 'Ustawienia', () => _navigateTo('/ustawienia')),
                Divider(height: 1, color: AppColors.divider),
                _buildMenuRow(Icons.logout, 'Logout', () => _navigateTo('/login')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MobileBottomMenu(
        currentIndex: 2.obs,
        onNavigation: (route) => _navigateTo(route),
      ),
    )
    );
  }

  Widget _buildMenuRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: AppColors.logo, size: 28),
            const SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.logo, size: 28),
              const SizedBox(width: 20),
              Text(
                text,
                style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }
}
