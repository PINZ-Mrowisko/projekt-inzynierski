// flutterfile configure - jesli zmieniacie cos w conf firestora to odswiezcie ustawienia

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/features/auth/screens/mobile/login_page_mobile.dart';
import 'package:the_basics/features/auth/screens/web/login_page.dart';
import 'package:the_basics/features/dashboard/screens/mobile/dashboard_mobile.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/employees/screens/employee_management.dart';
import 'package:the_basics/features/leaves/screens/mobile/employee_leaves_management_mobile.dart';
import 'package:the_basics/features/leaves/screens/mobile/manager_leaves_management_mobile.dart';
import 'package:the_basics/features/leaves/screens/web/employee_leaves_management.dart';
import 'package:the_basics/features/leaves/screens/web/manager_leaves_management.dart';
import 'package:the_basics/features/reports/screens/reports.dart';
import 'package:the_basics/features/schedules/screens/after_login/mobile/employee_main_calendar_mobile.dart';
import 'package:the_basics/features/schedules/screens/after_login/mobile/manager_main_calendar_mobile.dart';
import 'package:the_basics/features/schedules/screens/after_login/mobile/individual_calendar_mobile.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/employee_main_calendar.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/main_calendar_edit.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/individual_calendar.dart';
import 'package:the_basics/features/settings/screens/mobile/settings_mobile.dart';
import 'package:the_basics/features/settings/screens/web/settings.dart';
import 'package:the_basics/features/templates/screens/all_templates_screen.dart';
import 'package:the_basics/features/templates/screens/new_template_screen.dart';
import 'package:the_basics/features/user_profile/screens/web/user_profile.dart';
import 'package:the_basics/features/user_profile/screens/mobile/user_profile_mobile.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/bindings/app_bindings.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/employee_more_page_mobile.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/manager_more_page_mobile.dart';
import 'package:the_basics/utils/common_widgets/side_menu.dart';
import 'package:the_basics/utils/platform_wrapper.dart';
import 'package:the_basics/utils/route_observer.dart';
import 'package:the_basics/utils/themes/theme.dart';
import 'features/schedules/screens/after_login/web/main_calendar/manager_main_calendar.dart';
import 'features/tags/screens/tags.dart';
import 'features/schedules/screens/before_login/about_page.dart';
import 'features/schedules/screens/before_login/features_page.dart';
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
  Get.put(SideMenuController(), permanent: true);

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
        //GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/about', page: () => AboutPage()),
        GetPage(name: '/features', page: () => FeaturesPage()),

        GetPage(name: '/dashboard', page: () => PlatformWrapper(mobile: ManagerDashboardMobileScreen(), web: ManagerDashboardScreen())),
        GetPage(
          name: '/grafik-ogolny-kierownik',
          page:
              () => PopScope(
                canPop: false,
                child: PlatformWrapper(mobile: ManagerMainCalendarMobile(), web: ManagerMainCalendar())
              ),
        ),
        GetPage(
          name: '/grafik-ogolny-pracownicy',
          page:
              () => PopScope(
                canPop: false,
                child: PlatformWrapper(mobile: EmployeeMainCalendarMobile(), web: EmployeeMainCalendar())
              ),
        ),
        GetPage(name: '/grafik-ogolny-kierownik/edytuj-grafik', page: () => MainCalendarEdit()),
        
        GetPage(name: '/grafik-indywidualny', page: () => PlatformWrapper(mobile: IndividualCalendarMobile(), web: IndividualCalendar())),
        GetPage(name: '/wnioski-urlopowe-pracownicy', page: () => PlatformWrapper(mobile:EmployeeLeavesManagementMobilePage(), web: EmployeeLeavesManagementPage())),
        GetPage(name: '/wnioski-urlopowe-kierownik', page: () => PlatformWrapper(mobile: ManagerLeavesManagementMobilePage(), web: ManagerLeavesManagementPage())),
        
        GetPage(name: '/twoj-profil', page: () => PlatformWrapper(mobile: UserProfileScreenMobile(), web:  UserProfileScreen())),
        GetPage(name: '/tagi', page: () => TagsPage()),
        GetPage(name: '/pracownicy', page: () => EmployeeManagementPage()),
        GetPage(name: '/szablony', page: () => TemplatesPage()),
        GetPage(name: '/szablony/nowy-szablon', page: () => NewTemplatePage()),
        GetPage(name: '/szablony/edytuj-szablon', page: () => NewTemplatePage()),
        GetPage(name: '/raporty', page: () => ReportsScreen()),

        GetPage(name: '/ustawienia', page: () => PlatformWrapper(mobile: SettingsScreenMobile(), web: SettingsScreen())),
        GetPage(name: '/login', page: () => PlatformWrapper(mobile: LoginPageMobile(), web: LoginPage())),
        GetPage(name: '/wiecej-pracownicy', page: () => EmployeeMorePageMobile()),
        GetPage(name: '/wiecej-kierownik', page: () => ManagerMorePageMobile()),
      ],
      title: 'Mrowisko',
      //navigatorKey: navigatorKey,
      themeMode: ThemeMode.system,
      theme: MyAppTheme.lightTheme,
      darkTheme: MyAppTheme.darkTheme,
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
            return Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppColors.logo)),
            );
          } else {
            final userController = Get.find<UserController>();

                if (userController.isAdmin.value) {
                  return PlatformWrapper(
                    mobile: ManagerDashboardMobileScreen(),
                    web: ManagerDashboardScreen(),
                  );
                } else {
                  return PlatformWrapper(
                    mobile: EmployeeMainCalendarMobile(), 
                    web: EmployeeMainCalendar(),
                  );
                }
              }
            }
        // user is not logged in, show login page
        return PlatformWrapper(mobile: LoginPageMobile(), web: LoginPage());
      },
    );
  }
}
