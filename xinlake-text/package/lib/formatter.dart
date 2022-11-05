import 'package:flutter/services.dart';

class RemoveBreakFormatter extends TextInputFormatter {
  static final _lineWrap = RegExp(r"\r\n|\r|\n");

  final void Function()? _onLineWrap;

  RemoveBreakFormatter({void Function()? onLineWrap}) : _onLineWrap = onLineWrap;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains(_lineWrap)) {
      _onLineWrap?.call();

      final text = newValue.text.replaceAll(_lineWrap, '');
      return newValue.copyWith(
        text: text,
        composing: TextRange.empty,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return newValue;
  }
}
