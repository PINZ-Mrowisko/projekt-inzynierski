import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/data/repositiories/other/tags_repo.dart';
import 'package:the_basics/data/repositiories/user/user_repo.dart';
import 'package:the_basics/features/auth/screens/verify_email.dart';
import 'package:the_basics/features/schedules/models/tags_model.dart';

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

      /// MARKET
      /// 1 : create a market model locally
      /// 2 : save the market in firebase using the method from market_repo

      final uid = userCredential.user!.uid;
      final marketId = FirebaseFirestore.instance.collection('Markets').doc().id;

      final newMarket = MarketModel(
        id: marketId,
        marketName: marketName.text.trim(),
        createdBy: uid,
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save MarketModel
      final marketRepo = Get.put(MarketRepo());
      await marketRepo.saveMarket(newMarket);

      /// TAG
      /// 1 : add the kierownik tag to the FB

      final tagsId = FirebaseFirestore.instance.collection('Tags').doc().id;

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
          insertedAt: DateTime.now(),
          updatedAt: DateTime.now()
      );


      final userRepo = Get.put(UserRepo());
      userRepo.saveUser(newUser);

      // display a success msg with snackbar ??
      //print("sukces");
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    }
    catch (e) {
      // display error msg with snackbar
      //print(e.toString());

    } finally {

    }


  }
}