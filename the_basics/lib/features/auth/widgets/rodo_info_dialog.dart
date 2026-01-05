import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:the_basics/features/notifs/controllers/notif_controller.dart';


const String RODO_TEXT = '''
Informacja o przetwarzaniu danych osobowych 

Administratorem danych osobowych jest PSB Mrówka Lipno z siedzibą przy ulicy 3 Maja 1F, 87-600 Lipno. 

Dane osobowe pracowników są przetwarzane wyłącznie w celu: 
• założenia i obsługi konta użytkownika, 
• tworzenia i zarządzania grafikami pracy, 
• umożliwienia korzystania z funkcjonalności aplikacji, 

Podstawą prawną przetwarzania danych jest art. 6 ust. 1 lit. b oraz c RODO – przetwarzanie jest niezbędne do wykonania obowiązków wynikających ze stosunku pracy oraz przepisów prawa pracy. 

Dane osobowe są przetwarzane wyłącznie przez upoważnione osoby i nie są przekazywane innym podmiotom, 
z wyjątkiem podmiotów świadczących usługi IT na rzecz administratora. 

Dane będą przechowywane przez okres zatrudnienia pracownika. 

Każdej osobie przysługuje prawo dostępu do swoich danych oraz ich sprostowania, a także wniesienia skargi do Prezesa Urzędu Ochrony Danych Osobowych.
''';

class RodoInfoDialog extends StatelessWidget {
  const RodoInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authRepo = AuthRepo.instance;

      return WillPopScope(
      onWillPop: () async => false, // blokuje przycisk "Back"
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 800,
          height: 665,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    Get.isDarkMode
                        ? 'assets/mrowisko_logo_blue_dark_mode.svg'
                        : 'assets/mrowisko_logo_blue.svg',
                    height: 48,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Informacja RODO',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      RODO_TEXT,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: CustomButton(
                    text: 'Zapoznałem/am się',
                    width: 220,
                    onPressed: () async {
                      await userController.markRodoInfoSeen();
                      Get.back(); // zamykamy dialog
                      authRepo.afterLogin(); // kontynuujemy flow
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
