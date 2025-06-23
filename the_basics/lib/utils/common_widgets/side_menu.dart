import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import '/utils/app_colors.dart';

class SideMenuController extends GetxController {
  final RxBool _isExpanded = true.obs;
  final RxBool _darkMode = false.obs;

  bool get isExpanded => _isExpanded.value;
  bool get darkMode => _darkMode.value;

  void toggleExpanded() => _isExpanded.toggle();
  void toggleDarkMode() => _darkMode.toggle();

  void setExpanded(bool value) => _isExpanded.value = value;
  void setDarkMode(bool value) => _darkMode.value = value;
}

class SideMenu extends StatelessWidget {
  SideMenu({Key? key}) : super(key: key);

  final userController = Get.find<UserController>();
  final menuController = Get.put(SideMenuController());

  double get _scaleFactor {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    if (screenWidth < 1600) return 0.8;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: menuController.isExpanded ? 360 * _scaleFactor : 104 * _scaleFactor,
        height: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15 * _scaleFactor),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildMenuSection(),
                  ],
                ),
              ),
            ),
            _buildSettingsSection(),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: 24 * _scaleFactor,
        left: menuController.isExpanded ? 16 * _scaleFactor : 0,
        right: menuController.isExpanded ? 16 * _scaleFactor : 0,
        bottom: 24 * _scaleFactor,
      ),
      child: menuController.isExpanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: menuController.isExpanded ? 250 * _scaleFactor : 60 * _scaleFactor),
                    child: SvgPicture.asset(
                      'assets/mrowisko_logo_blue.svg',
                      height: 50 * _scaleFactor,
                      semanticsLabel: 'Mrowisko Logo',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.menu, 
                    size: 40 * _scaleFactor, 
                    color: AppColors.black),
                  onPressed: menuController.toggleExpanded,
                ),
              ],
            )
          : Center(
              child: IconButton(
                icon: Icon(Icons.menu, 
                  size: 30 * _scaleFactor, 
                  color: AppColors.black),
                onPressed: menuController.toggleExpanded,
              ),
            ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: menuController.isExpanded ? 8 * _scaleFactor : 0),
      child: Obx(() {
        final isAdmin = userController.isAdmin.value;
        return Column(
          children: isAdmin ? _buildAdminMenuItems() : _buildUserMenuItems(),
        );
      }),
    );
  }

  List<Widget> _buildAdminMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.dashboard,
        text: 'Dashboard',
        route: '/dashboard',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.schedule,
        text: 'Grafik ogólny',
        route: '/grafik-ogolny',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/grafik-indywidualny',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.sunny,
        text: 'Wnioski urlopowe',
        route: '/wnioski-urlopowe-kierownik',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.people,
        text: 'Pracownicy',
        route: '/pracownicy',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.tag,
        text: 'Tagi',
        route: '/tagi',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.view_module,
        text: 'Szablony',
        route: '/szablony',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.bar_chart,
        text: 'Raporty',
        route: '/raporty',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/gielda',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.person,
        text: 'Twój profil',
        route: '/twoj-profil',
      ),
    ];
  }

  List<Widget> _buildUserMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.schedule,
        text: 'Grafik ogólny',
        route: '/grafik-ogolny',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/grafik-indywidualny',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.sunny,
        text: 'Wnioski urlopowe',
        route: '/wnioski-urlopowe-pracownicy',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/gielda',
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.person,
        text: 'Twój profil',
        route: '/twoj-profil',
      ),
    ];
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: menuController.isExpanded ? 8 * _scaleFactor : 0),
          child: const Divider(color: AppColors.divider),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: menuController.isExpanded ? 8 * _scaleFactor : 0, 
            vertical: 16 * _scaleFactor,
          ),
          child: Column(
            children: [
              _buildDarkModeSwitch(),
              SizedBox(height: 4 * _scaleFactor),
              _buildMenuItem(
                icon: Icons.settings,
                text: 'Ustawienia',
                route: '/ustawienia',
              ),
              SizedBox(height: 4 * _scaleFactor),
              _buildMenuItem(
                icon: Icons.logout,
                text: 'Logout',
                route: '/login',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkModeSwitch() {
    return SizedBox(
      height: 56 * _scaleFactor,
      child: InkWell(
        onTap: menuController.toggleDarkMode,
        borderRadius: BorderRadius.circular(15 * _scaleFactor),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              menuController.isExpanded
                  ? SizedBox(
                      width: 56 * _scaleFactor,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(() => Switch(
                          value: menuController.darkMode,
                          onChanged: (value) => menuController.setDarkMode(value),
                          activeColor: AppColors.logo,
                        )),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Obx(() => Switch(
                          value: menuController.darkMode,
                          onChanged: (value) => menuController.setDarkMode(value),
                          activeColor: AppColors.logo,
                        )),
                      ),
                    ),
              if (menuController.isExpanded) ...[
                SizedBox(width: 12 * _scaleFactor),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: menuController.isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'Tryb ciemny',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28 * _scaleFactor,
                        color: AppColors.textColor2,
                      ),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required String route,
  }) {
    final isActive = Get.currentRoute == route;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: menuController.isExpanded ? 0 : 8 * _scaleFactor),
      child: SizedBox(
        height: 56 * _scaleFactor,
        child: Material(
          color: isActive ? AppColors.lightBlue : AppColors.transparent,
          borderRadius: BorderRadius.circular(15 * _scaleFactor),
          child: InkWell(
            onTap: () => _navigateTo(route),
            borderRadius: BorderRadius.circular(15 * _scaleFactor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  menuController.isExpanded
                      ? SizedBox(
                          width: 56 * _scaleFactor,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              icon,
                              size: 30 * _scaleFactor,
                              color: AppColors.textColor1,
                            ),
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: Tooltip(
                              message: text,
                              padding: EdgeInsets.all(8 * _scaleFactor),
                              textStyle: TextStyle(
                                fontSize: 14 * _scaleFactor,
                                color: AppColors.textColor2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pageBackground,
                                borderRadius: BorderRadius.circular(4 * _scaleFactor),
                              ),
                              preferBelow: false,
                              verticalOffset: 10 * _scaleFactor,
                              child: Icon(
                                icon,
                                size: 30 * _scaleFactor,
                                color: AppColors.textColor1,
                              ),
                            ),
                          ),
                        ),
                  if (menuController.isExpanded) ...[
                    SizedBox(width: 12 * _scaleFactor),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: menuController.isExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          text,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 28 * _scaleFactor,
                            color: AppColors.textColor2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }
}