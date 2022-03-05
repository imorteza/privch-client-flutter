import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:window_interface/window_placement.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

import 'package:privch/models/shadowsocks.dart';
import 'package:privch/models/server_manager.dart';
import 'package:privch/models/setting.dart';
import 'package:privch/models/server_state.dart';

class SettingManager {
  final Setting _data;

  /// TODO: better?
  /// indicate that server count or current server or sort mode has been changed.
  final ValueNotifier<ServerState> onServerState;

  /// indicate theme mode has been changed
  final ValueNotifier<ThemeMode> onThemeMode;

  int get httpPort => _data.httpPort;
  int get socksPort => _data.socksPort;
  int get dnsLocalPort => _data.dnsLocalPort;
  String get dnsRemoteAddress => _data.dnsRemoteAddress;

  WindowPlacement windowPlacement() => WindowPlacement(
        offsetX: _data.windowX,
        offsetY: _data.windowY,
        width: _data.windowW,
        height: _data.windowH,
      );

  Future<void> updateTunnelSetting({
    int? httpPort,
    int? socksPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    if (httpPort != null) {
      _data.httpPort = httpPort;
    }

    if (socksPort != null) {
      _data.socksPort = socksPort;
    }

    if (dnsLocalPort != null) {
      _data.dnsLocalPort = dnsLocalPort;
    }

    if (dnsRemoteAddress != null) {
      _data.dnsRemoteAddress = dnsRemoteAddress;
    }

    if (httpPort != null || socksPort != null || dnsLocalPort != null || dnsRemoteAddress != null) {
      await XinlakeTunnel.updateSettings(
        httpPort: httpPort,
        socksPort: socksPort,
        dnsLocalPort: dnsLocalPort,
        dnsRemoteAddress: dnsRemoteAddress,
      );
      await _data.save();
    }
  }

  Future<void> _onStateChanged() async {
    bool save = false;

    if (_data.serverSelId != onServerState.value.currentServer?.id) {
      _data.serverSelId = onServerState.value.currentServer?.id;
      save = true;

      // update vpn server
      final shadowsocks = onServerState.value.currentServer;
      if (shadowsocks != null) {
        await XinlakeTunnel.connectTunnel(
          shadowsocks.hashCode,
          shadowsocks.port,
          shadowsocks.address,
          shadowsocks.password,
          shadowsocks.encrypt,
        );
      }
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
    required Shadowsocks? currentServer,
  })  : _data = setting,
        onServerState = ValueNotifier(ServerState(
          currentServer: currentServer,
          serverCount: ServerManager.instance.servers.length,
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

    final setting = settingBox.values.first;
    final Shadowsocks? currentServer = (setting.serverSelId != null)
        ? ServerManager.instance.getServer(setting.serverSelId!)
        : null;

    _instance = SettingManager._constructor(
      setting: settingBox.values.first,
      currentServer: currentServer,
    );
  }
}
