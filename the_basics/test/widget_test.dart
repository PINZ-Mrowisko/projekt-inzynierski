import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_basics/features/auth/screens/login_page.dart';
import 'package:the_basics/features/auth/screens/reset_pswd.dart';
import 'package:the_basics/features/auth/screens/signup.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = ignoreOverflowErrors;

  group('LoginPage Widget Tests', () {
    late FlutterExceptionHandler? originalOnError;

    // pomagamy sobie w partyzanckiej walce z overflowem
    setUpAll(() {
      FlutterError.onError = ignoreOverflowErrors;
    });

    setUp(() {
      originalOnError = FlutterError.onError;
      FlutterError.onError = ignoreOverflowErrors;
    });

    tearDown(() {
      FlutterError.onError = originalOnError;
    });

    testWidgets('Should allow entering text into email field', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(const MaterialApp(home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1280)),
        child: LoginPage(),
      ),));

      // szukamy pola maila
      final emailField = find.byKey(const Key("email_field"));

      // sprawdzamy czy pole istnieje
      expect(emailField, findsOneWidget);

      // wpisujemy przykładowy email
      await tester.enterText(emailField, 'test@example.com');

      // odswiezamy widget po wpisaniu
      await tester.pump();

      // test czy pole zawiera wpisany tekst
      final textField = tester.widget<TextFormField>(emailField);
      expect(textField.controller?.text, 'test@example.com');
    });

    testWidgets('Should render all main UI elements', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(const MaterialApp(home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1280)),
        child: LoginPage(),
      ),));

      // Verify if main elements are present
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Hasło'), findsOneWidget);
    });

    testWidgets('Should show error for invalid email', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home: MediaQuery(
        data: MediaQueryData(size: Size(800, 1280)),
        child: LoginPage(),
      ),));

      // sprawdzamy przekikanie dla pustego maila
      await tester.enterText(find.byKey(const Key('email_field')), '');
      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();

      // powinnismy otrzymac validator msg
      expect(find.text('To pole jest wymagane.'), findsOneWidget);
    });
  });

  group('PswdResetPage Widget Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    testWidgets('Should display the email sent messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPswd(email: 'test@example.com'),
        ),
      );

      expect(find.text('Email został wysłany!'), findsOneWidget);
      expect(find.text('Na Twój adres email został wysłany link.'), findsOneWidget);
      expect(find.text('Kliknij go, aby ustawić nowe hasło.'), findsOneWidget);
    });

    testWidgets('Should show two buttons with correct texts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResetPswd(email: 'test@example.com'),
        ),
      );

      expect(find.text('Wróć do logowania'), findsOneWidget);
      expect(find.text('Wyślij wiadomość ponownie'), findsOneWidget);
    });

    testWidgets('Pressing "Wróć do logowania" navigates to LoginPage', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(
        GetMaterialApp(
          home: ResetPswd(email: 'test@example.com'),
          getPages: [
            GetPage(name: '/', page: () => ResetPswd(email: 'test@example.com')),
            GetPage(name: '/login', page: () => const LoginPage()),
          ],
        ),
      );

      // klikamy "Wróć do logowania"
      await tester.tap(find.text('Wróć do logowania'));
      await tester.pumpAndSettle();

      // spodziewamy się, że teraz jest LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
    });

  });

  group('SignUpPage Widget Tests', () {
    setUp(() {
      Get.testMode = true; // tryb testowy dla GetX zeby nam ladnie dzialalo
    });

    testWidgets('Should render all form fields and buttons', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(
        MaterialApp(
          home: SignUpPage(),
        ),
      );

      // Sprawdź czy pola istnieją po labelText
      expect(find.widgetWithText(TextFormField, 'Imię'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nazwisko'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Hasło'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Powtórz Hasło'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nazwa oddziału'), findsOneWidget);

      // Sprawdź przyciski
      expect(find.text('Stwórz konto'), findsOneWidget);
      expect(find.text('Masz już konto? '), findsOneWidget);
      //expect(find.text('Zaloguj się'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;

      await tester.pumpWidget(
        GetMaterialApp(
          home: SignUpPage(),
        ),
      );

      // znajdź ikonę "ukryj hasło" (oko)
      final eyeButtons = find.byIcon(Iconsax.eye_slash);

      expect(eyeButtons, findsNWidgets(2)); // mamy 2 pola hasła i oba powinny mieć przycisk

      // Kliknij pierwszy przycisk, żeby zmienić widoczność
      await tester.tap(eyeButtons.first);
      await tester.pump();

      // Po kliknięciu ikonka powinna się zmienić na 'eye' (widoczne hasło)
      expect(find.byIcon(Iconsax.eye), findsWidgets);
    });

  });

}
