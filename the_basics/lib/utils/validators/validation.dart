class MyValidator {
  static String? validateEmptyText(String? value) {
    if (value == null || value.isEmpty){
      return 'To pole jest wymagane.';
    }
    return null;
  }

  static String? validateEmail(String? value){
    if (value == null || value.isEmpty){
      return 'Wpisz poprawny adres email.';
    }
    // check email format with a regex exp
    final emailRegexExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if(!emailRegexExp.hasMatch(value)) {
      return 'Wpisz poprawny adres email.';
    }

    return null;
  }

  static String? validatePassword(String? value){
    if (value == null || value.isEmpty){
      return 'Wpisz poprawne hasło.';
    }

    if (value.length <= 8){
      return 'Hasło musi mieć przynajmniej 8 znaków.';
    }

    // jeśli chcecie można tu dodać walidacje typu zawieranie znaków specjalnych, liczb, etc.

    return null;
  }

}