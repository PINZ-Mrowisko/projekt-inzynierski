import 'package:flutter/material.dart';
import 'package:the_basics/features/schedules/widgets/logged_navbar_admin.dart';
import '../../widgets/navbar.dart';

class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: const [
          LoggedAdminNavBar(),
          Expanded(
            child: Center(
              child: Text(
                'To jest strona główna juz po zalogowaniu.',
                style: TextStyle(fontSize: 45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
