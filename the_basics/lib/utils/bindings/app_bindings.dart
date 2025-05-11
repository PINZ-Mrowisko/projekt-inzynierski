import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';

import '../../data/repositiories/other/tags_repo.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.put(AuthRepo());
    Get.put(UserRepo());
    Get.put(TagsRepo());
    // Get.lazyPut(() => AuthRepo(), fenix: true);
    // Get.lazyPut(() => UserRepo(), fenix: true);
    // Get.lazyPut(() => TagsRepo(), fenix: true);

    // Controllers - kolejność ma znaczenie !
    // chwilowo test podejscia z inicializacja kontrolerow w auth_repo
    // Get.lazyPut(() => UserController(), fenix: true);
    // Get.lazyPut(() => TagsController(), fenix: true);

    Get.put(UserController());
    Get.put(TagsController());
  }
}

