/*
  Xinlake Liu
  2022-01

  - onSaved is not a good practice
 */

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:xinlake_text/generator.dart';
import 'package:xinlake_text/validator.dart';

import '../../global.dart';

part 'shadowsocks07.g.dart';

/// flutter packages pub run build_runner build --delete-conflicting-outputs
///
@HiveType(typeId: 1)
class Shadowsocks extends HiveObject {
  // server
  @HiveField(0)
  String encrypt;
  @HiveField(1)
  String password;
  @HiveField(2)
  String address;
  @HiveField(3)
  int port;

  // remarks
  @HiveField(4)
  String name;
  @HiveField(5)
  String modified;
  @HiveField(6)
  int order; // TODO: not used

  // statistics
  @HiveField(7)
  String geoLocation;
  @HiveField(8)
  int responseTime;

  // properties
  String get id => "$address:$port";

  // change callback
  VoidCallback? _onSaved;
  set onSaved(VoidCallback? value) => _onSaved = value;

  //shadowsocks 1.9.0
  static final RegExp _regUrl = RegExp(r'^(.+?):(.*)@(.+?):(\d+?)$');

  Shadowsocks({
    // server
    required this.encrypt,
    required this.password,
    required this.address,
    required this.port,
    // remarks
    String? name,
    int? order,
    // statistics
    String? geoLocation,
    int? responseTime,
  })  : name = name ?? "$address-$port",
        modified = gDateFormat.format(DateTime.now()),
        order = order ?? 0,
        responseTime = responseTime ?? 0,
        geoLocation = geoLocation ?? "";

  factory Shadowsocks.createDefault() {
    return Shadowsocks(
      encrypt: "aes-256-gcm",
      password: "",
      address: "",
      port: -1,
      name: "new server",
    );
  }

  factory Shadowsocks.createRandom() {
    final random = Random();
    return Shadowsocks(
      port: 1000 + (random.nextDouble() * 60000).toInt(),
      address: Generator.randomIp(),
      password: Generator.randomPassword(),
      encrypt: ssEncryptMethods[random.nextInt(ssEncryptMethods.length)],
    );
  }

  factory Shadowsocks.fromMap(Map<String, dynamic> map) {
    return Shadowsocks(
      encrypt: map["encrypt"] ?? "",
      password: map["password"] ?? "",
      address: map["address"] ?? "",
      port: map["port"] ?? 0,
      // remarks
      name: map["name"],
      order: map["order"],
      // statistics
      geoLocation: map["geoLocation"],
      responseTime: map["responseTime"],
    );
  }

  Map<String, Object> toMap() {
    return {
      // server
      "port": port,
      "address": address,
      "password": password,
      "encrypt": encrypt,

      // remarks
      "name": name,
      "modified": modified,
      "order": order,

      // statistics
      "responseTime": responseTime,
      "geoLocation": geoLocation,
    };
  }

  bool get isValid {
    return (port > 0 && port < 65536) &&
        password.isNotEmpty &&
        encrypt.isNotEmpty &&
        name.isNotEmpty &&
        modified.isNotEmpty &&
        Validator.isURL(address);
  }

  /// batter?
  Shadowsocks copy() {
    return Shadowsocks.fromMap(toMap());
  }

  /// ss://BASE64-ENCODED-STRING-WITHOUT-PADDING#TAG
  /// BASE64-WITHOUT-PADDING: ss://method:password@hostname:port
  /// https://shadowsocks.org/en/config/quick-guide.html
  String encodeBase64() {
    final bytes = utf8.encode("$encrypt:$password@$address:$port");
    final code = base64.encode(bytes);
    return "ss://$code";
  }

  static Shadowsocks? parserQrCode(String qrCode) {
    if (!qrCode.startsWith("ss://")) {
      return null;
    }

    // remove prefix
    final ssInfo = qrCode.substring(5);
    if (ssInfo.contains("@")) {
      // shadowsocks-android v4 generated format
      return parseV4(ssInfo);
    }

    return parse(ssInfo);
  }

  static Shadowsocks? parse(String ssInfo) {
    final ssBase64Tag = ssInfo.split("#");
    if (ssBase64Tag.isEmpty) {
      return null;
    }

    final bytes = base64.decode(ssBase64Tag[0]);
    final ssUrl = utf8.decode(bytes);

    // TODO: allow multi match?
    final match = _regUrl.firstMatch(ssUrl);
    if (match != null && match.groupCount >= 4) {
      try {
        final encrypt = match.group(1) as String;
        final password = match.group(2) as String;
        final address = match.group(3) as String;
        final portString = match.group(4) as String;
        final port = int.parse(portString);

        final tag = (ssBase64Tag.length == 2) ? ssBase64Tag[1] : null;
        return Shadowsocks(
          encrypt: encrypt,
          password: password,
          address: address,
          port: port,
          name: tag,
        );
      } catch (exception) {
        // ignored
      }
    }

    return null;
  }

  /// format: {BASE64@ADDRESS:PORT}, base64: {ENCRYPT:PASSWORD}
  /// This format is generated by shadowsocks-android v4
  static Shadowsocks? parseV4(String ssInfo) {
    // check ss code
    String ssEncryptBase64, ssAddressInfo;
    try {
      final info = ssInfo.split("@");
      ssEncryptBase64 = base64.normalize(info[0]);
      ssAddressInfo = info[1];
    } catch (exception) {
      return null;
    }

    // decode encrypt info
    final ssEncryptBytes = base64.decode(ssEncryptBase64);
    final ssEncryptInfo = utf8.decode(ssEncryptBytes);

    final ssEncryptPassword = ssEncryptInfo.split(":");
    if (ssEncryptPassword.length != 2) {
      return null;
    }

    final encrypt = ssEncryptPassword[0];
    final password = ssEncryptPassword[1];

    // parse address info
    final ssAddressPort = ssAddressInfo.split(":");
    if (ssAddressPort.length != 2) {
      return null;
    }

    final address = ssAddressPort[0];
    try {
      final port = int.parse(ssAddressPort[1]);
      return Shadowsocks(
        encrypt: encrypt,
        password: password,
        address: address,
        port: port,
      );
    } catch (exception) {
      // ignored
    }

    return null;
  }

  @override
  Future<void> save() async {
    await super.save();
    _onSaved?.call(); // TODO: batter?
  }

  @override
  bool operator ==(other) {
    return other is Shadowsocks && other.port == port && other.address == address;
  }

  @override
  int get hashCode => Object.hash(port, address);
}

/// values will stored in lowercase
const List<String> ssEncryptMethods = [
  "2022-BLAKE3-AES-128-GCM",
  "2022-BLAKE3-AES-256-GCM",
  "2022-BLAKE3-CHACHA20-POLY1305",
  "2022-BLAKE3-CHACHA8-POLY1305",
  "CHACHA20-IETF-POLY1305",
  "AES-128-GCM",
  "AES-256-GCM",
  "PLAIN",
  "NONE",
];
