import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';

class MobileBottomMenu extends StatelessWidget {
  final RxInt currentIndex;
  final Function(String route)? onNavigation;

  const MobileBottomMenu({
    super.key,
    required this.currentIndex,
    this.onNavigation
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: currentIndex.value,
            onTap: (index) {
              currentIndex.value = index;
              _navigateToPage(index, context);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.logo,
            unselectedItemColor: AppColors.textColor2,
            elevation: 0,
            iconSize: 28,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              height: 1.2,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                activeIcon: Icon(Icons.access_time),
                label: 'Grafik ogólny',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Grafik indywidualny',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'Więcej',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index, BuildContext context) {
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name != '/grafik-ogolny') {
          _navigateTo('/grafik-ogolny');
        }
        break;
      case 1:
        _showPlaceholderSnackbar('Grafik indywidualny - w budowie');
        break;
      case 2:
        _showPlaceholderSnackbar('Menu więcej - w budowie');
        break;
    }
  }

  void _showPlaceholderSnackbar(String message) {
    Get.snackbar(
      'Informacja',
      message,
      backgroundColor: AppColors.lightBlue,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _navigateTo(String route) {
    if (Get.currentRoute != route) {
      if (onNavigation != null) {
        onNavigation!(route);
      } else {
        Get.toNamed(route);
      }
    }
  }
}

