import 'package:flutter/material.dart';
import '../../../data/repositiories/auth/auth_repo.dart';
import '../screens/about_page.dart';
import '../screens/docs_page.dart';
import '../screens/features_page.dart';
import '../screens/home_page.dart';
import '../../auth/screens/login_page.dart';

class LoggedAdminNavBar extends StatelessWidget {
  const LoggedAdminNavBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Image.asset('assets/mrowisko_logo2.JPG', height: 40),
              ),
              const SizedBox(width: 40),
              _NavItem(title: 'Grafik ogólny', page: const HomePage()),
              _NavItem(title: 'Grafik Indywidualny', page: const AboutPage()),
              _NavItem(title: 'Pracownicy', page: const FeaturesPage()),
              _NavItem(title: 'costam costam', page: const DocsPage()),
            ],
          ),
          const Spacer(),

          InkWell(
            onTap: () {
              AuthRepo.instance.logout();
            },
            child: Row(
              children: const [
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
}

class _NavItem extends StatelessWidget {
  final String title;
  final Widget page;

  const _NavItem({required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
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
