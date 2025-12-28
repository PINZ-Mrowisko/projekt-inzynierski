// to jest ten brzydki very basic screen który się wyświetlał w złych miejscach
// być może można tu wstawić promo page ale na razie chowam go żeby zdiagnozować gdzie indziej się wyświetla


import 'package:flutter/material.dart';

import '../../../../utils/common_widgets/navbar.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

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
                'To jest strona główna w ktorej wyswietlamy wszystkie informacje promocyjne dla niezalogowanych mrowkowiczów',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
