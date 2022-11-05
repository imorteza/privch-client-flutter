import 'dart:async';

import 'package:flutter/services.dart';

class XinQrcode {
  static const MethodChannel _channel = MethodChannel('xinlake_qrcode');

  /// android only
  static Future<String?> fromCamera({
    int? accentColor,
    String? prefix,
    bool? playBeep,
    bool? frontFace,
  }) async {
    try {
      final String? code = await _channel.invokeMethod('fromCamera', {
        "accentColor": accentColor,
        "prefix": prefix,
        "playBeep": playBeep,
        "frontFace": frontFace,
      });
      return code;
    } catch (exception) {
      return null;
    }
  }

  /// windows only
  static Future<List<String>?> readScreen() async {
    try {
      final List<String>? codeList = await _channel.invokeListMethod('readScreen');
      return codeList;
    } catch (exception) {
      return null;
    }
  }

  static Future<List<String>?> readImage(List<String>? imageList) async {
    try {
      final List<String>? codeList = await _channel.invokeListMethod('readImage', {
        "imageList": imageList,
      });
      return codeList;
    } catch (exception) {
      return null;
    }
  }
}
