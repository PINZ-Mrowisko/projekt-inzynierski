import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/algorithm_model.dart';

class ScheduleController extends GetxController {
  var schedule = <DaySchedule>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> loadSchedule() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        errorMessage.value = 'Użytkownik niezalogowany.';
        isLoading.value = false;
        return;
      }

      final idToken = await user.getIdToken(); // 🔑 Pobieramy Firebase token

      final response = await http.get(
        Uri.parse('https://algorytm-166365589002.europe-central2.run.app/run-algorithm'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        schedule.value = jsonData.map((e) => DaySchedule.fromJson(e)).toList();
      } else {
        errorMessage.value = 'Błąd: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Przepraszamy! Aktualnie ta usługa jest dostępna tylko dla mrówek w Lipnie';
      //errorMessage.value = 'Wystąpił błąd: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
