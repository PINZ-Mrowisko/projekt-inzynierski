import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/other/leave_repo.dart';
import 'package:the_basics/data/repositiories/other/notifs/token_repo.dart';
import 'package:the_basics/data/repositiories/other/schedule_repo.dart';
import 'package:the_basics/data/repositiories/other/template_repo.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/notifs/controllers/notif_controller.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/calendar_state_manager.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/templates/controllers/template_controller.dart';
import 'package:the_basics/utils/platform_controller.dart';

import '../../data/repositiories/other/tags_repo.dart';
import '../../features/schedules/controllers/schedule_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Repositories
    //todo if something is broken uncomment the get put auth repo
    //Get.put(AuthRepo());
    Get.put(UserRepo());
    Get.put(TagsRepo());
    Get.put(LeaveRepo());
    Get.put(TemplateRepo());
    Get.put(TokenRepo());
    Get.put(ScheduleRepo());
    //Get.put(SettingsRepo());
    // Get.lazyPut(() => AuthRepo(), fenix: true);
    // Get.lazyPut(() => UserRepo(), fenix: true);
    // Get.lazyPut(() => TagsRepo(), fenix: true);

    // Controllers - kolejność ma znaczenie !
    // chwilowo test podejscia z inicializacja kontrolerow w auth_repo
    // Get.lazyPut(() => UserController(), fenix: true);
    // Get.lazyPut(() => TagsController(), fenix: true);

    // we initialize the controllers at the start of the app,but dont call the initialzie methods withing yet, that happends only after login
    Get.put(PlatformController());
    Get.put(UserController());
    Get.put(TagsController());
    Get.put(LeaveController());
    Get.put(TemplateController());
    Get.put(NotificationController());
    Get.put(SchedulesController());
    Get.put(CalendarStateManager());
  }
}

