import 'package:flutter/material.dart';

import '../../../../utils/common_widgets/navbar.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

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
                'Tutaj funkcjonalności...',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
