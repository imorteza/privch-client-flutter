import 'dart:math';

class Generator {
  static const String _lettersLowercase = "abcdefghijklmnopqrstuvwxyz"; // cSpell: disable-line
  static const String _lettersUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; // cSpell: disable-line
  static const String _numbers = "0123456789";
  static const String _special = "@#=+!£\$%&?[](){}";

  /// original source code is
  /// [here](https://github.com/imtheguna/random_password_generator/blob/main/lib/random_password_generator.dart)
  /// * return random password
  static String randomPassword({
    bool letters = true,
    bool uppercase = false,
    bool numbers = false,
    bool specialChar = false,
    int passwordLength = 8,
  }) {
    assert(letters || uppercase || specialChar || numbers);

    final String _sourceChars = (letters ? _lettersLowercase : '') +
        (uppercase ? _lettersUppercase : '') +
        (numbers ? _numbers : '') +
        (specialChar ? _special : '');

    // generate random password
    String _result = "";
    while (_result.length < passwordLength) {
      final index = Random.secure().nextInt(_sourceChars.length);
      _result += _sourceChars[index];
    }

    return _result;
  }

  /// return random ip address
  static String randomIp() {
    final a = Random.secure().nextInt(255);
    final b = Random.secure().nextInt(255);
    final c = Random.secure().nextInt(255);
    final d = Random.secure().nextInt(255);
    return "$a.$b.$c.$d";
  }
}
