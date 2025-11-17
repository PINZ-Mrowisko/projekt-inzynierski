import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/screens/mobile/verify_email_mobile.dart';
import 'package:the_basics/features/auth/screens/web/verify_email.dart';
import 'package:the_basics/features/tags/models/tags_model.dart';
import 'package:the_basics/utils/platform_wrapper.dart';
import '../../../data/repositiories/other/market_repo.dart';
import '../models/market_model.dart';
import '../models/user_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final pswd1 = TextEditingController();
  final pswd2 = TextEditingController();
  final marketName = TextEditingController();

  // using obs state management makes it less taxing to redraw
  // the screen anytime something happens
  // the main widget gets wrapped in an obx widget, which makes it observe the .obs values
  // this makes it so we dont need stateful widgets

  final hidePswd1 = true.obs;
  final hidePswd2 = true.obs;

  // allows us to access data from the form
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  // Future<void> assignRole(String uid) async {
  //   try {
  //     HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable('setCustomClaims');
  //     final result = await callable.call({'uid': uid});
  //     print('Custom claim set result: ${result.data}');
  //   } catch (e) {
  //     print('Error setting custom claims: $e');
  //     rethrow; // bubble up if needed
  //   }
  // }



  /// deals with our Sign Up method
  Future<void> signUp() async {
    try {
      // nie wiem czy tak sie robi w webówkach ale można dodać ekran ładowania?
      // albo po prostu circularProgressIndicator w poprzednim ekranie

      /// form validation
      if (!signUpFormKey.currentState!.validate()){
        //form key not valid
        //return error
        return;
      }

      /// register user in FB
      final userCredential = await AuthRepo.instance.registerWithEmailAndPassword(email.text.trim(), pswd1.text.trim());

      await Future.delayed(const Duration(milliseconds: 200));

      /// MARKET
      /// 1 : create a market model locally
      /// 2 : save the market in firebase using the method from market_repo

      final uid = userCredential.user!.uid;
      final marketId = FirebaseFirestore.instance.collection('Markets').doc().id;

      /// USER
      /// 1 : create a user model locally
      /// 2 : save the user in firebase using the method from user_repo

      final newUser = UserModel(
          id: userCredential.user!.uid,
          firstName: firstName.text.trim(),
          lastName: lastName.text.trim(),
          email: email.text.trim(),
          marketId: marketId,
          tags: ['Kierownik'],
          role: 'admin',
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          hasLoggedIn: true,
        scheduleNotifs: true,
        leaveNotifs: true
      );

      final newUserTemp = UserModel(
          id: userCredential.user!.uid,
          firstName: '',
          lastName: '',
          email: '',
          marketId: marketId,
          tags: [],
          role: 'admin',
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now()
      );

      /// this saves the User in the User collection, for now lets leave it
      final userRepo = Get.put(UserRepo());
      userRepo.saveUser(newUserTemp);


      // /// presave settings for manager
      // final settings = SettingsModel(
      //     userId: userCredential.user!.uid,
      //     insertedAt: DateTime.now(),
      //     updatedAt: DateTime.now(),
      //     newSchedule: true,
      //     leaveRequests: false,
      //     leaveStatus: true
      // );
      //
      // final settingsRepo = Get.put(SettingsRepo());
      // await settingsRepo.saveSettings(settings, marketId);



      final newMarket = MarketModel(
        id: marketId,
        marketName: marketName.text.trim(),
        createdBy: uid,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save MarketModel
      final marketRepo = Get.put(MarketRepo());
      await marketRepo.saveMarket(newMarket, newUser, uid);

      /// TAG
      /// 1 : add the kierownik tag to the FB - but now in a specific Market

      final tagsId = FirebaseFirestore.instance
          .collection('Markets')
          .doc(marketId)
          .collection('Tags')
          .doc()
          .id;

      final newTag = TagsModel(
        id: tagsId,
        tagName: 'Kierownik',
        description: 'Szef szefów',
        marketId: marketId,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tagRepo = Get.put(TagsRepo());
      await tagRepo.saveTag(newTag);


      Get.to(() => PlatformWrapper(mobile: VerifyEmailScreenMobile(email: email.text.trim()), web: VerifyEmailScreen(email: email.text.trim())));

      email.clear();
      firstName.clear();
      lastName.clear();
      pswd1.clear();
      pswd2.clear();
      marketName.clear();
    }
    catch (e) {
      // display error msg with snackbar
      //print(e.toString());

    } finally {

    }


  }
}