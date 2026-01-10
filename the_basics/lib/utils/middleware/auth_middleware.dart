import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;

  // dla niezalogowanych userów zawsze zmuszamy do loginu
    if (user == null || user.isAnonymous) {
      return const RouteSettings(name: '/login');
    }

    return null; // inaczej null, czyli dostęp do strony
  }
}
