import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositiories/auth/auth_repo.dart';

class GetxRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _saveCurrentRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _saveCurrentRoute(newRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _saveCurrentRoute(previousRoute);
    }
  }

  void _saveCurrentRoute(Route route) {
    if (route.settings.name != null ) {
      final AuthRepo authRepo = Get.find<AuthRepo>();
      authRepo.saveLastRoute(route.settings.name!);
    }
  }
}