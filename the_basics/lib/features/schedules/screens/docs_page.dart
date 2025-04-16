import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class DocsPage extends StatelessWidget {
  const DocsPage({super.key});

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
                'Tutaj dokumentacja projektu.',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
