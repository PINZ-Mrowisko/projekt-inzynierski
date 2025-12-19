import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
import 'package:the_basics/features/auth/controllers/login_controller.dart';


// Mocki
class MockAuthRepo extends Mock implements AuthRepo {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late LoginController loginController;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();

    // Rejestracja w Get
    Get.reset();
    Get.put<AuthRepo>(mockAuthRepo);

    loginController = LoginController();
  });

  group('LoginController emailAndPasswordSignIn', () {
    test('succeeds when login is correct', () async {
      loginController.email.text = 'test@example.com';
      loginController.pswd.text = 'password123';
      loginController.rememberMe.value = true;

      // Mockowanie odpowiedzi AuthRepo
      when(mockAuthRepo.loginWithEmailAndPassword(
        any as String,
        any as String,
        any as bool,
      )).thenAnswer((_) async => MockUserCredential());

      await loginController.emailAndPasswordSignIn();

      expect(loginController.errorMessage.value, '');
      expect(loginController.email.text, '');
      expect(loginController.pswd.text, '');
      expect(loginController.rememberMe.value, false);

      verify(mockAuthRepo.loginWithEmailAndPassword(
        'test@example.com', 'password123', true
      )).called(1);
    });

    test('sets errorMessage on FirebaseAuthException', () async {
      loginController.email.text = 'wrong@example.com';
      loginController.pswd.text = 'wrongpass';

      when(mockAuthRepo.loginWithEmailAndPassword(
        any as String,
        any as String,
        any as bool,
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await loginController.emailAndPasswordSignIn();

      expect(loginController.errorMessage.value, 'Nieprawidłowy email lub hasło.');
    });
  });
}
