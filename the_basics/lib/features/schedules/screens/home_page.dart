import 'package:flutter/material.dart';
import '../../../widgets/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: const [
          NavBar(),
          Expanded(
            child: Center(
              child: Text(
                'To jest strona główna.',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
