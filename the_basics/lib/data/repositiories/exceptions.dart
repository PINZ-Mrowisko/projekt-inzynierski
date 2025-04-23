class MyFirebaseException implements Exception {
  final String code;

  MyFirebaseException(this.code);

  String get message {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';

      case 'unavailable':
        return 'The server is currently unavailable. Please try again later.';

      case 'weak-password':
        return 'The password provided is too weak.';

      case 'email-already-in-use':
        return 'The account already exists for that email.';

      case 'invalid-email':
        return 'The email address is malformed.';

      case 'wrong-password':
        return 'Incorrect password.';

      default:
        return 'A Firebase error occurred. Please try again.';
    }
  }
}

class MyFirebaseAuthException implements Exception {
  final String code;

  MyFirebaseAuthException(this.code);

  String get message {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';

      case 'unavailable':
        return 'The server is currently unavailable. Please try again later.';

      case 'weak-password':
        return 'The password provided is too weak.';

      case 'email-already-in-use':
        return 'The account already exists for that email.';

      case 'invalid-email':
        return 'The email address is malformed.';

      case 'wrong-password':
        return 'Incorrect password.';

      default:
        return 'A Firebase error occurred. Please try again.';
    }
  }
}

class MyFormatException implements Exception {
  const MyFormatException();

  String get message => 'Invalid data format.';
}

class MyPlatformException implements Exception {
  final String code;

  MyPlatformException(this.code);

  String get message {
    switch (code) {
      case 'network_error':
        return 'Network error. Please check your internet connection.';

      case 'device_not_supported':
        return 'This feature is not supported on your device.';

      default:
        return 'A platform error occurred. Please try again.';
    }
  }
}
