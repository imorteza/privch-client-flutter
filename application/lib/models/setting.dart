import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'setting.g.dart';

/// `flutter packages pub run build_runner build --delete-conflicting-outputs`
/// * `themeModeIndex` is defaults to `ThemeMode.system.index`
/// * 2021-11-29
@HiveType(typeId: 0)
class Setting extends HiveObject {
  @HiveField(0)
  int windowX;
  @HiveField(1)
  int windowY;
  @HiveField(2)
  int windowW;
  @HiveField(3)
  int windowH;
  @HiveField(4)
  bool windowTopMost;

  @HiveField(5)
  String? serverSelId;
  @HiveField(6)
  int sortModeIndex;
  @HiveField(7)
  int themeModeIndex;

  @HiveField(8)
  int httpPort;
  @HiveField(9)
  int socksPort;
  @HiveField(10)
  int dnsLocalPort;
  @HiveField(11)
  String dnsRemoteAddress;

  Setting()
      : // preference
        windowX = 0,
        windowY = 0,
        windowW = 0,
        windowH = 0,
        windowTopMost = false,
        // status
        serverSelId = null,
        sortModeIndex = 0,
        themeModeIndex = ThemeMode.system.index,
        // networking
        httpPort = 7039,
        socksPort = 7029,
        dnsLocalPort = 5450,
        dnsRemoteAddress = "8.8.8.8";
}
