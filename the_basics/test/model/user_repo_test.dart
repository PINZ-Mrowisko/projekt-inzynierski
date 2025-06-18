// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:mockito/mockito.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:the_basics/data/repositiories/auth/auth_repo.dart';
// import 'package:the_basics/data/repositiories/other/leave_repo.dart';
// import 'package:the_basics/data/repositiories/other/tags_repo.dart';
// import 'package:the_basics/data/repositiories/user/user_repo.dart';
// import 'package:the_basics/features/auth/models/user_model.dart';
// import 'package:the_basics/features/employees/controllers/user_controller.dart';
// import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
// import 'package:the_basics/features/tags/controllers/tags_controller.dart';
//
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}
// class MockUser extends Mock implements User {}
// class MockUserCredential extends Mock implements UserCredential {}
// class MockSharedPreferences extends Mock implements SharedPreferences {}
//
// class MockUserRepo extends Mock implements UserRepo {}
// class MockTagsRepo extends Mock implements TagsRepo {}
// class MockLeaveRepo extends Mock implements LeaveRepo {}
//
// class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
//
// class MockUserController extends Mock implements UserController {
//   @override
//   Rx<UserModel> employee = UserModel.empty().obs;
//
//   @override
//   final RxBool isLoading = true.obs;
//
//   @override
//   final RxString errorMessage = ''.obs;
//
//   @override
//   final UserRepo userRepo = MockUserRepo(); // Add mock user repo
//
//   @override
//   final localStorage = GetStorage();
//
//   @override
//   final RxString searchQuery = ''.obs;
//
//   @override
//   RxList<UserModel> allEmployees = <UserModel>[].obs;
//
//   @override
//   final RxList<UserModel> filteredEmployees = <UserModel>[].obs;
//
//   @override
//   final RxBool isAdmin = false.obs;
//
//   @override
//   void onInit() {}
//   @override
//   void onReady() {}
//   @override
//   void onClose() {}
// }
//
// class MockTagsController extends Mock implements TagsController {
//   @override
//   void onInit() {}
//   @override
//   void onReady() {}
//   @override
//   void onClose() {}
// }
//
// class MockLeaveController extends Mock implements LeaveController {
//   @override
//   void onInit() {}
//   @override
//   void onReady() {}
//   @override
//   void onClose() {}
// }
//
// void main() async {
//   late AuthRepo authRepo;
//   late MockFirebaseAuth mockFirebaseAuth;
//   late MockSharedPreferences mockSharedPreferences;
//   late MockUserController mockUserController;
//   late MockTagsController mockTagsController;
//   late MockLeaveController mockLeaveController;
//
//   // late MockUserRepo mockUserRepo;
//   late MockTagsRepo mockTagsRepo;
//   late MockLeaveRepo mockLeaveRepo;
//
//   late MockFirebaseFirestore mockFirebaseFirestore;
//
//   TestWidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'test',
//         appId: 'test',
//         messagingSenderId: 'test',
//         projectId: 'test',
//       ),
//     );
//   } catch (e) {
//     print('Firebase already initialized: $e');
//   }
//
//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//
//     try {
//       await Firebase.initializeApp(
//         options: const FirebaseOptions(
//           apiKey: 'test_api_key',
//           appId: 'test_app_id',
//           messagingSenderId: 'test_messaging_sender_id',
//           projectId: 'test_project_id',
//         ),
//       ); // Simple initialization for testing
//     } catch (e) {
//       print('Firebase already initialized or error during init: $e');
//     }
//   });
//
//   setUp(() async {
//     mockFirebaseAuth = MockFirebaseAuth();
//     mockSharedPreferences = MockSharedPreferences();
//     mockUserController = MockUserController();
//     mockTagsController = MockTagsController();
//     mockLeaveController = MockLeaveController();
//     //mockUserRepo = MockUserRepo();
//     //mockTagsRepo = MockTagsRepo();
//     //mockLeaveRepo = MockLeaveRepo();
//     mockFirebaseFirestore = MockFirebaseFirestore();
//
//     // we set GetX to test mode
//     Get.testMode = true;
//
//     authRepo = AuthRepo(mockSharedPreferences, firebaseAuth: mockFirebaseAuth);
//     final testUserRepo = TestUserRepo(firebaseFirestore: mockFirebaseFirestore);
//     final testLeaveRepo = TestLeaveRepo(firebaseFirestore: mockFirebaseFirestore);
//     final testTagsRepo = TestTagsRepo(firebaseFirestore: mockFirebaseFirestore);
//
//     // we need to register our repos because our fake controllers still depend on them
//     Get.put<UserRepo>(testUserRepo);
//     Get.put<LeaveRepo>(testLeaveRepo);
//     Get.put<TagsRepo>(testTagsRepo);
//
//     // register mock controllers with GetX
//     Get.put<UserController>(mockUserController);
//     Get.put<TagsController>(mockTagsController);
//     Get.put<LeaveController>(mockLeaveController);
//
//     // we create an instance of AuthRepo with mocked dependencies
//
//     // and reset GetX instances after each test
//     addTearDown(() {
//       Get.reset();
//     });
//   });
//
//   group('AuthRepo - registerWithEmailAndPassword', () {
//     const email = 'test@gmail.com';
//     const password = 'ogromnazaba1';
//
//     test('should return UserCredential on successful registration', () async {
//       final mockUserCredential = MockUserCredential();
//
//       when(mockFirebaseAuth.createUserWithEmailAndPassword(
//           email: email,
//           password: password
//       )).thenAnswer((_) async => mockUserCredential);
//
//       final result = await authRepo.registerWithEmailAndPassword(
//           email, password);
//
//       // we expect the 'result' of the method call to be the same 'mockUserCredential' we set up
//       expect(result, mockUserCredential);
//
//       verify(mockFirebaseAuth.createUserWithEmailAndPassword(
//           email: email,
//           password: password
//       )).called(1);
//     });
//   });
// }
//
// class TestUserRepo extends UserRepo {
//   final FirebaseFirestore _testFirebaseFirestore;
//
//   TestUserRepo({required FirebaseFirestore firebaseFirestore})
//       : _testFirebaseFirestore = firebaseFirestore,
//         super(firebaseFirestore: firebaseFirestore); // Pass to parent
//
//   @override
//   FirebaseFirestore get _db => _testFirebaseFirestore;
// }
//
// class TestLeaveRepo extends LeaveRepo {
//   final FirebaseFirestore _testFirebaseFirestore;
//
//   TestLeaveRepo({required FirebaseFirestore firebaseFirestore})
//       : _testFirebaseFirestore = firebaseFirestore,
//         super(firebaseFirestore: firebaseFirestore);
//
//   @override
//   FirebaseFirestore get _db => _testFirebaseFirestore;
// }
//
// class TestTagsRepo extends TagsRepo {
//   final FirebaseFirestore _testFirebaseFirestore;
//
//   TestTagsRepo({required FirebaseFirestore firebaseFirestore})
//       : _testFirebaseFirestore = firebaseFirestore,
//         super(firebaseFirestore: firebaseFirestore);
//
//   @override
//   FirebaseFirestore get _db => _testFirebaseFirestore;
// }