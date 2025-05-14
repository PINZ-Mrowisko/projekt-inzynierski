import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import '/utils/app_colors.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final userController = UserController.instance;
  bool _isExpanded = true;
  bool _darkMode = false;

  double get _scaleFactor {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1600) return 0.8;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 360 * _scaleFactor : 104 * _scaleFactor,
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
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: 24 * _scaleFactor,
        left: _isExpanded ? 16 * _scaleFactor : 0,
        right: _isExpanded ? 16 * _scaleFactor : 0,
        bottom: 24 * _scaleFactor,
      ),
      child: _isExpanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: _isExpanded ? 250 * _scaleFactor : 60 * _scaleFactor),
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
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            )
          : Center(
              child: IconButton(
                icon: Icon(Icons.menu, 
                  size: 30 * _scaleFactor, 
                  color: AppColors.black),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8 * _scaleFactor : 0),
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
        onTap: () => _navigateTo('/dashboard'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.schedule,
        text: 'Grafik ogólny',
        route: '/main-calendar',
        onTap: () => _navigateTo('/main-calendar'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/personal-schedule',
        onTap: () => _navigateTo('/personal-schedule'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.sunny,
        text: 'Wnioski urlopowe',
        route: '/wnioski-urlopowe',
        onTap: () => _navigateTo('/wnioski-urlopowe'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.people,
        text: 'Pracownicy',
        route: '/zarzadzaj-pracownikami',
        onTap: () => _navigateTo('/zarzadzaj-pracownikami'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.tag,
        text: 'Tagi',
        route: '/tags',
        onTap: () => _navigateTo('/tags'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.view_module,
        text: 'Szablony',
        route: '/templates',
        onTap: () => _navigateTo('/templates'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.bar_chart,
        text: 'Raporty',
        route: '/reports',
        onTap: () => _navigateTo('/reports'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/market',
        onTap: () => _navigateTo('/market'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.person,
        text: 'Twój profil',
        route: '/profile',
        onTap: () => _navigateTo('/profile'),
      ),
    ];
  }

  List<Widget> _buildUserMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.schedule,
        text: 'Grafik ogólny',
        route: '/main-calendar',
        onTap: () => _navigateTo('/main-calendar'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/personal-schedule',
        onTap: () => _navigateTo('/personal-schedule'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.sunny,
        text: 'Wnioski urlopowe',
        route: '/wnioski-urlopowe',
        onTap: () => _navigateTo('/wnioski-urlopowe'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/market',
        onTap: () => _navigateTo('/market'),
      ),
      SizedBox(height: 4 * _scaleFactor),
      _buildMenuItem(
        icon: Icons.person,
        text: 'Twój profil',
        route: '/profile',
        onTap: () => _navigateTo('/profile'),
      ),
    ];
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8 * _scaleFactor : 0),
          child: const Divider(color: AppColors.divider),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _isExpanded ? 8 * _scaleFactor : 0, 
            vertical: 16 * _scaleFactor,
          ),
          child: Column(
            children: [
              _buildDarkModeSwitch(),
              SizedBox(height: 4 * _scaleFactor),
              _buildMenuItem(
                icon: Icons.settings,
                text: 'Ustawienia',
                route: '/settings',
                onTap: () => _navigateTo('/settings'),
              ),
              SizedBox(height: 4 * _scaleFactor),
              _buildMenuItem(
                icon: Icons.logout,
                text: 'Logout',
                route: '/logout',
                onTap: () => _navigateTo('/logout'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required String route,
    bool isSwitch = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onChanged,
  }) {
    bool isActive = Get.currentRoute == route;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 0 : 8 * _scaleFactor),
      child: SizedBox(
        height: 56 * _scaleFactor,
        child: Material(
          color: isActive ? AppColors.lightBlue : AppColors.transparent,
          borderRadius: BorderRadius.circular(15 * _scaleFactor),
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.lightBlue,
            highlightColor: AppColors.lightBlue,
            splashColor: AppColors.lightBlue.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15 * _scaleFactor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * _scaleFactor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _isExpanded
                      ? SizedBox(
                          width: 56 * _scaleFactor,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: isSwitch
                                ? Switch(
                                    value: isActive,
                                    onChanged: onChanged,
                                    activeColor: AppColors.logo,
                                  )
                                : Icon(
                                    icon,
                                    size: 30 * _scaleFactor,
                                    color: AppColors.textColor1,
                                  ),
                          ),
                        )
                      : Expanded(
                          child: Center(
                            child: isSwitch
                                ? Switch(
                                    value: isActive,
                                    onChanged: onChanged,
                                    activeColor: AppColors.logo,
                                  )
                                : Tooltip(
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
                  if (_isExpanded && !isSwitch) ...[
                    SizedBox(width: 12 * _scaleFactor),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
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

  Widget _buildDarkModeSwitch() {
    return SizedBox(
      height: 56 * _scaleFactor,
      child: InkWell(
        onTap: () => setState(() => _darkMode = !_darkMode),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isExpanded
                ? SizedBox(
                    width: 56 * _scaleFactor,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: _darkMode,
                        onChanged: (value) => setState(() => _darkMode = value),
                        activeColor: AppColors.logo,
                      ),
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Switch(
                        value: _darkMode,
                        onChanged: (value) => setState(() => _darkMode = value),
                        activeColor: AppColors.logo,
                      ),
                    ),
                  ),
            if (_isExpanded) ...[
              SizedBox(width: 12 * _scaleFactor),
              Expanded(
                child: AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Text(
                    'Tryb ciemny',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28 * _scaleFactor,
                      color: AppColors.textColor2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    debugPrint('Navigating to: $route');
    Navigator.pushNamed(context, route);
  }
}