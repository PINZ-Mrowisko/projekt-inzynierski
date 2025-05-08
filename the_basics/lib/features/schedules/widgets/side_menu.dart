import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/controllers/user_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 360 : 104,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
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
        top: 24,
        left: _isExpanded ? 16 : 0,
        right: _isExpanded ? 16 : 0,
        bottom: 24,
      ),
      child: _isExpanded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: _isExpanded ? 250 : 60),
                    child: SvgPicture.asset(
                      'assets/mrowisko_logo_blue.svg',
                      height: 50,
                      semanticsLabel: 'Mrowisko Logo',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, size: 40, color: AppColors.black),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            )
          : Center(
              child: IconButton(
                icon: const Icon(Icons.menu, size: 30, color: AppColors.black),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8 : 0),
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
        icon: Icons.schedule,
        text: 'Grafik ogólny',
        route: '/main-calendar',
        onTap: () => _navigateTo('/main-calendar'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/personal-schedule',
        onTap: () => _navigateTo('/personal-schedule'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.people,
        text: 'Pracownicy',
        route: '/employees',
        onTap: () => _navigateTo('/zarzadzaj-pracownikami'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.tag,
        text: 'Tagi',
        route: '/tags',
        onTap: () => _navigateTo('/tags'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.view_module,
        text: 'Szablony',
        route: '/templates',
        onTap: () => _navigateTo('/templates'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.bar_chart,
        text: 'Raporty',
        route: '/reports',
        onTap: () => _navigateTo('/reports'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/market',
        onTap: () => _navigateTo('/market'),
      ),
      const SizedBox(height: 30),
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
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.calendar_today,
        text: 'Grafik indywidualny',
        route: '/personal-schedule',
        onTap: () => _navigateTo('/personal-schedule'),
      ),
      const SizedBox(height: 30),
      _buildMenuItem(
        icon: Icons.change_circle_outlined,
        text: 'Giełda',
        route: '/market',
        onTap: () => _navigateTo('/market'),
      ),
      const SizedBox(height: 30),
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
          padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8 : 0),
          child: const Divider(color: AppColors.divider),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8 : 0, vertical: 16),
          child: Column(
            children: [
              _buildDarkModeSwitch(),
              const SizedBox(height: 30),
              _buildMenuItem(
                icon: Icons.settings,
                text: 'Ustawienia',
                route: '/settings',
                onTap: () => _navigateTo('/settings'),
              ),
              const SizedBox(height: 30),
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
    final currentRoute = ModalRoute.of(context)?.settings.name;
    bool isActive = currentRoute == route;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 0 : 8),
      child: SizedBox(
        height: 56,
        child: Material(
          color: isActive ? AppColors.lightBlue : AppColors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.lightBlue,
            highlightColor: AppColors.lightBlue,
            splashColor: AppColors.lightBlue.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _isExpanded
                      ? SizedBox(
                          width: 56,
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
                                    size: 30,
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
                                : Icon(
                                    icon,
                                    size: 30,
                                    color: AppColors.textColor1,
                                  ),
                          ),
                        ),
                  if (_isExpanded && !isSwitch) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          text,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 28,
                            color: Color(0xFF49454F),
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
      height: 56,
      child: InkWell(
        onTap: () => setState(() => _darkMode = !_darkMode),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isExpanded
                ? SizedBox(
                    width: 56,
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
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: const Text(
                    'Tryb ciemny',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 28,
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
