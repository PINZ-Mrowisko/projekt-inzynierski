// flutterfile configure - jesli zmieniacie cos w conf firestora to odswiezcie ustawienia

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/features/auth/screens/login_page.dart';
import 'package:the_basics/features/employees/screens/employee_management.dart';
import 'package:the_basics/features/leaves/screens/employee_leaves_management.dart';
import 'package:the_basics/features/leaves/screens/manager_leaves_management.dart';
import 'package:the_basics/features/schedules/screens/after_login/main_calendar_edit.dart';
import 'package:the_basics/features/schedules/screens/after_login/placeholder_page.dart';
import 'package:the_basics/features/settings/screens/settings.dart';
import 'package:the_basics/features/templates/screens/algoritm_screen.dart';
import 'package:the_basics/features/templates/screens/all_templates_screen.dart';
import 'package:the_basics/utils/bindings/app_bindings.dart';
import 'package:the_basics/utils/route_observer.dart';
import 'package:the_basics/utils/themes/theme.dart';
import 'features/schedules/screens/after_login/main_calendar.dart';
import 'features/tags/screens/tags.dart';
import 'features/schedules/screens/before_login/about_page.dart';
import 'features/schedules/screens/before_login/features_page.dart';
import 'features/schedules/screens/before_login/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/templates/controllers/algorithm_controller.dart';
import 'firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  //print('Prefs initialized with keys: ${prefs.getKeys()}');
  Get.put<AuthRepo>(AuthRepo(prefs), permanent: true);
  Get.put(ScheduleController());

  final authRepo = Get.find<AuthRepo>();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('pl'),
      supportedLocales: const [Locale('pl'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      //initialRoute: '/',
      initialBinding: AppBindings(),
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/about', page: () => AboutPage()),
        GetPage(name: '/features', page: () => FeaturesPage()),

        GetPage(name: '/dashboard', page: () => PlaceholderPage()),
        GetPage(
          name: '/grafik-ogolny',
          page:
              () => PopScope(
                canPop: false,
                child: const MainCalendar(),
              ),
        ),
        GetPage(name: '/grafik-ogolny/edytuj-grafik', page: () => MainCalendarEdit()),
        GetPage(name: '/grafik-indywidualny', page: () => PlaceholderPage()),
        GetPage(name: '/wnioski-urlopowe-pracownicy', page: () => EmployeeLeavesManagementPage()),
        GetPage(name: '/wnioski-urlopowe-kierownik', page: () => ManagerLeavesManagementPage()),
        GetPage(name: '/gielda', page: () => PlaceholderPage()),
        GetPage(name: '/twoj-profil', page: () => PlaceholderPage()),
        GetPage(name: '/tagi', page: () => TagsPage()),
        GetPage(name: '/pracownicy', page: () => EmployeeManagementPage()),
        GetPage(name: '/szablony', page: () => TemplatesPage()),
        GetPage(name: '/raporty', page: () => PlaceholderPage()),

        GetPage(name: '/ustawienia', page: () => SettingsScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
      ],
      title: 'Mrowisko',
      themeMode: ThemeMode.light,
      theme: MyAppTheme.lightTheme,
      transitionDuration: const Duration(
        milliseconds: 0,
      ), // so the pages don't slide around all crazy
      debugShowCheckedModeBanner: false,
      //home: isLoggedIn? MainCalendar() :MainCalendar(),
      home: AuthWrapper(),
      navigatorObservers: [GetxRouteObserver()],
    );
  }
}

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth auth = FirebaseAuth.instance;
//
//     return StreamBuilder<User?>(
//       stream: auth.userChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData && (!snapshot.data!.isAnonymous)) {
//           return MainCalendar();
//         }
//         return LoginPage();
//       },
//     );
//   }
// }

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final AuthRepo authRepo = Get.find<AuthRepo>();

    return StreamBuilder<User?>(
      stream: auth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && (!snapshot.data!.isAnonymous)) {
          // user is logged in
          final String? lastRoute = authRepo.getLastRoute();
          if (lastRoute != null && Get.currentRoute != lastRoute) {
            // we navigate to the last saved route if it's not the current route
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.currentRoute != lastRoute) {
                //Get.offAllNamed(lastRoute);
                Get.offNamed(lastRoute);
              }
            });
            // lets return a loading indicator  while navigating
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return MainCalendar();
          }
        }
        // user is not logged in, show login page
        return LoginPage();
      },
    );
  }
}
