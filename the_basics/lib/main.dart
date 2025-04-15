// flutterfile configure - jesli zmieniacie cos w conf firestora to odswiezcie ustawienia

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/utils/themes/theme.dart';
import 'features/schedules/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:get_storage/get_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize local storage
  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then(
    //if user is authenticated, we will move them to the home screen
    //otherwise login/register screen
      (FirebaseApp value) => Get.put(AuthRepo()),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mrowisko',
      themeMode: ThemeMode.light,
      theme: MyAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
