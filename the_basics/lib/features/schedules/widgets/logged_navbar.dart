import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
import '../../../data/repositiories/auth/auth_repo.dart';
import '../screens/before_login/home_page.dart';

/// THIS NAVBAR IS DISPLAYED AFTER USERS LOG IN
/// through reading the data of the current logged user it decides whether to display the admin version or normal worker one

class LoggedNavBar extends StatelessWidget {
  const LoggedNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    //final tagsController = Get.find<TagsController>(); // Use find instead of put to avoid duplicate controllers

    return Obx(() {
      final isAdmin = userController.isAdmin.value;

      /// Admin navbar
      if (isAdmin) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(230, 229, 235, 1).withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.offAll(() => const HomePage());
                    },
                    child: Image.asset('assets/mrowisko_logo2.JPG', height: 40),
                  ),
                  const SizedBox(width: 40),
                  _NavItem(title: 'Grafik ogólny', routeName: '/main-calendar',),
                  _NavItem(title: 'Grafik Indywidualny', routeName: '/main-calendar'),
                  _NavItem(title: 'Tagi', routeName: '/tags'),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  AuthRepo.instance.logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Wyloguj sie',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      /// Regular user navbar
      else {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(230, 229, 235, 1).withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.offAll(() => const HomePage());
                    },
                    child: Image.asset('assets/mrowisko_logo2.JPG', height: 40),
                  ),
                  const SizedBox(width: 40),
                  _NavItem(title: 'Grafik ogólny', routeName: '/main-calendar',),
                  _NavItem(title: 'Grafik Indywidualny', routeName: '/main-calendar'),
                  _NavItem(title: 'Tagi', routeName: '/tags'),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  AuthRepo.instance.logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'Wyloguj sie',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}
class _NavItem extends StatelessWidget {
  final String title;
  final String routeName;

  const _NavItem({required this.title, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(routeName);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}