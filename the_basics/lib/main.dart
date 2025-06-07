// flutterfile configure - jesli zmieniacie cos w conf firestora to odswiezcie ustawienia

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/features/auth/screens/login_page.dart';
import 'package:the_basics/features/employees/screens/employee_management.dart';
import 'package:the_basics/utils/bindings/app_bindings.dart';
import 'package:the_basics/utils/themes/theme.dart';
import 'features/schedules/screens/after_login/main_calendar.dart';
import 'features/tags/screens/tags.dart';
import 'features/schedules/screens/before_login/about_page.dart';
import 'features/schedules/screens/before_login/features_page.dart';
import 'features/schedules/screens/before_login/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
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
        GetPage(name: '/main-calendar', page: () => MainCalendar()),
        GetPage(name: '/about', page: () => AboutPage()),
        GetPage(name: '/tags', page: () => TagsPage()),
        GetPage(name: '/features', page: () => FeaturesPage()),
        GetPage(
          name: '/zarzadzaj-pracownikami',
          page: () => EmployeeManagementPage(),
        ),
      ],
      title: 'Mrowisko',
      themeMode: ThemeMode.light,
      theme: MyAppTheme.lightTheme,

      debugShowCheckedModeBanner: false,
      //home: isLoggedIn? MainCalendar() :MainCalendar(),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && (!snapshot.data!.isAnonymous)) {
          return MainCalendar();
        }
        return LoginPage();
      },
    );
  }
}
