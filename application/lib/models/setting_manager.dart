import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'package:privch/models/placement.dart';
import 'package:privch/models/server_manager.dart';
import 'package:privch/models/setting.dart';
import 'package:privch/models/server_state.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

class SettingManager {
  final Setting _data;

  /// TODO: better?
  /// indicate that server count or current server or sort mode has been changed.
  final ValueNotifier<ServerState> onServerState;

  /// indicate theme mode has been changed
  final ValueNotifier<ThemeMode> onThemeMode;

  int get proxyPort => _data.proxyPort;
  int get dnsLocalPort => _data.dnsLocalPort;
  String get dnsRemoteAddress => _data.dnsRemoteAddress;

  Placement windowPlacement() => Placement(
        offsetX: _data.windowX,
        offsetY: _data.windowY,
        width: _data.windowW,
        height: _data.windowH,
      );

  Future<void> updateVpnSetting({
    int? proxyPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    // TODO: update vpn settings

    if (proxyPort != null) {
      _data.proxyPort = proxyPort;
    }

    if (dnsLocalPort != null) {
      _data.dnsLocalPort = dnsLocalPort;
    }

    if (dnsRemoteAddress != null) {
      _data.dnsRemoteAddress = dnsRemoteAddress;
    }

    if (proxyPort != null || dnsLocalPort != null || dnsRemoteAddress != null) {
      await _data.save();
    }
  }

  Future<void> _onStateChanged() async {
    bool save = false;

    if (_data.serverSelId != onServerState.value.serverSelId) {
      _data.serverSelId = onServerState.value.serverSelId;

      // TODO: temp
      final ss = ServerManager.instance.servers.firstWhere(
        (element) => element.id == _data.serverSelId,
      );
      XinlakeTunnel.startShadowsocks(
        ss.hashCode,
        ss.port,
        ss.address,
        ss.password,
        ss.encrypt,
      );

      save = true;
    }

    if (_data.sortModeIndex != onServerState.value.sortMode.index) {
      _data.sortModeIndex = onServerState.value.sortMode.index;
      save = true;
    }

    if (save) {
      await _data.save();
    }
  }

  Future<void> _onThemeChanged() async {
    _data.themeModeIndex = onThemeMode.value.index;
    await _data.save();
  }

  /// single instance, use `instance` property, call `initialize()` first
  ///
  SettingManager._constructor({
    required Setting setting,
  })  : _data = setting,
        onServerState = ValueNotifier(ServerState(
          serverCount: ServerManager.instance.servers.length,
          serverSelId: setting.serverSelId,
          sortMode: ServerSortMode.values[setting.sortModeIndex],
        )),
        onThemeMode = ValueNotifier(
          ThemeMode.values[setting.themeModeIndex],
        ) {
    onServerState.addListener(() async => await _onStateChanged());
    onThemeMode.addListener(() async => await _onThemeChanged());
  }

  static late final SettingManager _instance;
  static SettingManager get instance => _instance;

  /// load data and create instance
  static Future<void> initialize() async {
    Box<Setting> settingBox = await Hive.openBox("setting");
    if (settingBox.isEmpty) {
      settingBox.add(Setting());
    }

    _instance = SettingManager._constructor(
      setting: settingBox.values.first,
    );
  }
}
