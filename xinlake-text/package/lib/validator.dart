//cspell:disable

import 'dart:math';

class Validator {
  static final RegExp _email = RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  static final RegExp _ipv4Maybe = RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
  static final RegExp _ipv6 = RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

  static final RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
  static final RegExp _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
  static final RegExp _numeric = RegExp(r'^-?[0-9]+$');

  static final RegExp _hexadecimal = RegExp(r'^[0-9a-fA-F]+$');

  static final RegExp _base64 =
      RegExp(r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

  static final RegExp _creditCard = RegExp(
      r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$');

  static final RegExp _isbn10Maybe = RegExp(r'^(?:[0-9]{9}X|[0-9]{10})$');
  static final RegExp _isbn13Maybe = RegExp(r'^(?:[0-9]{13})$');

  static final Map _uuid = {
    '3': RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$'),
    '4': RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
    '5': RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$'),
    'all': RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$')
  };

  static final RegExp _multibyte = RegExp(r'[^\x00-\x7F]');
  static final RegExp _ascii = RegExp(r'^[\x00-\x7F]+$');

  /// check if the string is a port number
  static int? getPortNumber(String value) {
    int? port = int.tryParse(value, radix: 10);
    if (port == null || port < 0 || port > 65535) {
      return null;
    }

    return port;
  }

  /// check if the string [value] is an email
  static bool isEmail(String value) {
    return _email.hasMatch(value.toLowerCase());
  }

  /// check if the string [value] is a URL
  /// * [protocols] sets the list of allowed protocols
  /// * [requireTld] sets if TLD is required
  /// * [requireProtocol] is a `bool` that sets if protocol is required for validation
  static bool isURL(
    String value, {
    List<String?> protocols = const ['http', 'https', 'ftp'],
    bool requireTld = true,
    bool requireProtocol = false,
  }) {
    if (value.isEmpty || value.length > 2083 || value.startsWith('mailto:')) {
      return false;
    }

    dynamic protocol, user, auth, host, hostname, port, portStr, path, query, hash, split;

    // check protocol
    split = value.split('://');
    if (split.length > 1) {
      protocol = _shift(split);
      if (!protocols.contains(protocol)) {
        return false;
      }
    } else if (requireProtocol == true) {
      return false;
    }
    value = split.join('://');

    // check hash
    split = value.split('#');
    value = _shift(split);
    hash = split.join('#');
    if (hash != null && hash != "" && RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = value.split('?');
    value = _shift(split);
    query = split.join('?');
    if (query != null && query != "" && RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = value.split('/');
    value = _shift(split);
    path = split.join('/');
    if (path != null && path != "" && RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = value.split('@');
    if (split.length > 1) {
      auth = _shift(split);
      if (auth.indexOf(':') >= 0) {
        auth = auth.split(':');
        user = _shift(auth);
        if (!RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        if (!RegExp(r'^\S*$').hasMatch(user)) {
          return false;
        }
      }
    }

    // check hostname
    hostname = split.join('@');
    split = hostname.split(':');
    host = _shift(split);
    if (split.length > 0) {
      portStr = split.join(':');
      try {
        port = int.parse(portStr, radix: 10);
      } catch (e) {
        return false;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(portStr) || port <= 0 || port > 65535) {
        return false;
      }
    }

    if (!isIP(host) && !isFQDN(host, requireTld: requireTld) && host != 'localhost') {
      return false;
    }

    return true;
  }

  /// check if the string [value] is IP [version] 4 or 6
  /// * [version] is a String or an `int`.
  static bool isIP(String value, [/*<String | int>*/ version]) {
    version = version.toString();
    if (version == 'null') {
      return isIP(value, 4) || isIP(value, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(value)) {
        return false;
      }
      var parts = value.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(value);
  }

  /// check if the string [value] is a fully qualified domain name (e.g. domain.com).
  /// * [requireTld] sets if TLD is required
  static bool isFQDN(String value, {bool requireTld = true}) {
    var parts = value.split('.');
    if (requireTld) {
      var tld = parts.removeLast();
      if (parts.isEmpty || !RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }

    for (var part in parts) {
      if (!RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' || part[part.length - 1] == '-' || part.contains('---')) {
        return false;
      }
    }
    return true;
  }

  /// check if the string [value] contains only letters (a-zA-Z).
  static bool isAlpha(String value) {
    return _alpha.hasMatch(value);
  }

  /// check if the string [value] contains only numbers
  static bool isNumeric(String value) {
    return _numeric.hasMatch(value);
  }

  /// check if the string [value] contains only letters and numbers
  static bool isAlphanumeric(String value) {
    return _alphanumeric.hasMatch(value);
  }

  /// check if a string [value] is base64 encoded
  static bool isBase64(String value) {
    return _base64.hasMatch(value);
  }

  /// check if the string  [value]is a hexadecimal number
  static bool isHexadecimal(String value) {
    return _hexadecimal.hasMatch(value);
  }

  /// check if the length of the string [value] falls in a range
  static bool isLength(String value, int min, [int? max]) {
    return value.length >= min && (max == null || value.length <= max);
  }

  /// check if the string is a UUID (version 3, 4 or 5).
  static bool isUUID(String value, [version]) {
    if (version == null) {
      version = 'all';
    } else {
      version = version.toString();
    }

    RegExp? pat = _uuid[version];
    return (pat != null && pat.hasMatch(value.toUpperCase()));
  }

  /// check if the string is a credit card
  static bool isCreditCard(String value) {
    String sanitized = value.replaceAll(RegExp(r'[^0-9]+'), '');
    if (!_creditCard.hasMatch(sanitized)) {
      return false;
    }

    // Luhn algorithm
    int sum = 0;
    String digit;
    bool shouldDouble = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      digit = sanitized.substring(i, (i + 1));
      int tmpNum = int.parse(digit);

      if (shouldDouble == true) {
        tmpNum *= 2;
        if (tmpNum >= 10) {
          sum += ((tmpNum % 10) + 1);
        } else {
          sum += tmpNum;
        }
      } else {
        sum += tmpNum;
      }
      shouldDouble = !shouldDouble;
    }

    return (sum % 10 == 0);
  }

  /// check if the string is an ISBN (version 10 or 13)
  static bool isISBN(String value, [version]) {
    if (version == null) {
      return isISBN(value, '10') || isISBN(value, '13');
    }

    version = version.toString();

    String sanitized = value.replaceAll(RegExp(r'[\s-]+'), '');
    int checksum = 0;

    if (version == '10') {
      if (!_isbn10Maybe.hasMatch(sanitized)) {
        return false;
      }
      for (int i = 0; i < 9; i++) {
        checksum += (i + 1) * int.parse(sanitized[i]);
      }
      if (sanitized[9] == 'X') {
        checksum += 10 * 10;
      } else {
        checksum += 10 * int.parse(sanitized[9]);
      }
      return (checksum % 11 == 0);
    } else if (version == '13') {
      if (!_isbn13Maybe.hasMatch(sanitized)) {
        return false;
      }
      var factor = [1, 3];
      for (int i = 0; i < 12; i++) {
        checksum += factor[i % 2] * int.parse(sanitized[i]);
      }
      return (int.parse(sanitized[12]) - ((10 - (checksum % 10)) % 10) == 0);
    }

    return false;
  }

  /// check if the string contains one or more multibyte chars
  static bool isMultibyte(String value) {
    return _multibyte.hasMatch(value);
  }

  /// check if the string contains ASCII chars only
  static bool isAscii(String value) {
    return _ascii.hasMatch(value);
  }

  static final _threeDigit = RegExp(r'^\d{3}$');
  static final _fourDigit = RegExp(r'^\d{4}$');
  static final _fiveDigit = RegExp(r'^\d{5}$');
  static final _sixDigit = RegExp(r'^\d{6}$');
  static final _postalCodePatterns = {
    "AD": RegExp(r'^AD\d{3}$'),
    "AT": _fourDigit,
    "AU": _fourDigit,
    "BE": _fourDigit,
    "BG": _fourDigit,
    "CA": RegExp(r'^[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][\s\-]?\d[ABCEGHJ-NPRSTV-Z]\d$',
        caseSensitive: false),
    "CH": _fourDigit,
    "CZ": RegExp(r'^\d{3}\s?\d{2}$'),
    "DE": _fiveDigit,
    "DK": _fourDigit,
    "DZ": _fiveDigit,
    "EE": _fiveDigit,
    "ES": _fiveDigit,
    "FI": _fiveDigit,
    "FR": RegExp(r'^\d{2}\s?\d{3}$'),
    "GB": RegExp(r'^(gir\s?0aa|[a-z]{1,2}\d[\da-z]?\s?(\d[a-z]{2})?)$', caseSensitive: false),
    "GR": RegExp(r'^\d{3}\s?\d{2}$'),
    "HR": RegExp(r'^([1-5]\d{4}$)'),
    "HU": _fourDigit,
    "ID": _fiveDigit,
    "IL": _fiveDigit,
    "IN": _sixDigit,
    "IS": _threeDigit,
    "IT": _fiveDigit,
    "JP": RegExp(r'^\d{3}\-\d{4}$'),
    "KE": _fiveDigit,
    "LI": RegExp(r'^(948[5-9]|949[0-7])$'),
    "LT": RegExp(r'^LT\-\d{5}$'),
    "LU": _fourDigit,
    "LV": RegExp(r'^LV\-\d{4}$'),
    "MX": _fiveDigit,
    "NL": RegExp(r'^\d{4}\s?[a-z]{2}$', caseSensitive: false),
    "NO": _fourDigit,
    "PL": RegExp(r'^\d{2}\-\d{3}$'),
    "PT": RegExp(r'^\d{4}\-\d{3}?$'),
    "RO": _sixDigit,
    "RU": _sixDigit,
    "SA": _fiveDigit,
    "SE": RegExp(r'^\d{3}\s?\d{2}$'),
    "SI": _fourDigit,
    "SK": RegExp(r'^\d{3}\s?\d{2}$'),
    "TN": _fourDigit,
    "TW": RegExp(r'^\d{3}(\d{2})?$'),
    "UA": _fiveDigit,
    "US": RegExp(r'^\d{5}(-\d{4})?$'),
    "ZA": _fourDigit,
    "ZM": _fiveDigit
  };

  static bool isPostalCode(String value, String locale) {
    final pattern = _postalCodePatterns[locale];
    return pattern?.hasMatch(value) ?? false;
  }

  /// check password strong and return double value [0-1]. original source code is
  /// [here](https://github.com/imtheguna/random_password_generator/blob/main/lib/random_password_generator.dart)
  static double checkPassword(String password) {
    // if [password] is empty return 0.0
    if (password.isEmpty) {
      return 0.0;
    }

    final double bonus;
    if (RegExp(r'^[a-z]*$').hasMatch(password)) {
      bonus = 1.0;
    } else if (RegExp(r'^[a-z0-9]*$').hasMatch(password)) {
      bonus = 1.2;
    } else if (RegExp(r'^[a-zA-Z]*$').hasMatch(password)) {
      bonus = 1.3;
    } else if (RegExp(r'^[a-z\-_!?]*$').hasMatch(password)) {
      bonus = 1.3;
    } else if (RegExp(r'^[a-zA-Z0-9]*$').hasMatch(password)) {
      bonus = 1.5;
    } else {
      bonus = 1.8;
    }

    // return double value [0-1]
    double logistic(double x) => 1.0 / (1.0 + exp(-x));

    // return double value [0-1]
    double curve(double x) => logistic((x / 3.0) - 4.0);

    // return double value [0-1]
    return curve(password.length * bonus);
  }

  // internal --------------------------------------------------------------------------------------
  static _shift(List list) {
    if (list.isNotEmpty) {
      var first = list.first;
      list.removeAt(0);
      return first;
    }
    return null;
  }
}
