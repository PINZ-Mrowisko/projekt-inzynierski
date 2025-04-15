import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepo extends GetxController {
  static AuthRepo get instance => Get.find();

  final deviceStorage = GetStorage();

  // this func gets called first after storage is initialized
  // @override
  // void onReady() {
  //
  // }
}