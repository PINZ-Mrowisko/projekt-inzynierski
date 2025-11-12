import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';

class MobileBottomMenu extends StatelessWidget {
  final RxInt currentIndex;
  final Function(String route)? onNavigation;

  MobileBottomMenu({
    super.key,
    required this.currentIndex,
    this.onNavigation,
  });

  final userController = Get.find<UserController>();

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
    final isAdmin = userController.isAdmin.value;

    switch (index) {
      case 0:
        final route = isAdmin ? '/grafik-ogolny-kierownik' : '/grafik-ogolny-pracownicy';
        if (ModalRoute.of(context)?.settings.name != route) {
          _navigateTo(route);
        }
        break;

      case 1:
        if (ModalRoute.of(context)?.settings.name != '/grafik-indywidualny') {
          _navigateTo('/grafik-indywidualny');
        }
        break;

      case 2:
        final route = isAdmin ? '/wiecej-kierownik' : '/wiecej-pracownicy';
        if (ModalRoute.of(context)?.settings.name != route) {
          _navigateTo(route);
        }
        break;

      default:
        break;
    }
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
