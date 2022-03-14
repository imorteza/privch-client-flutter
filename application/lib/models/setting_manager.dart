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
  // TODO: multi stream?
  /// indicate that server count or current server or sort mode has been changed.
  final ServerState serverState;

  final Setting _settings;

  /// indicate theme mode has been changed
  final ValueNotifier<ThemeMode> onThemeMode;

  int get httpPort => _settings.httpPort;
  int get socksPort => _settings.socksPort;
  int get dnsLocalPort => _settings.dnsLocalPort;
  String get dnsRemoteAddress => _settings.dnsRemoteAddress;

  WindowPlacement get windowPlacement => WindowPlacement(
        x: _settings.windowX,
        y: _settings.windowY,
        width: _settings.windowW,
        height: _settings.windowH,
      );

  Future<void> updateWindowPlacement(WindowPlacement value) async {
    _settings.windowX = value.x;
    _settings.windowY = value.y;
    _settings.windowW = value.width;
    _settings.windowH = value.height;
    await _settings.save();
  }

  Future<void> updateTunnelSetting({
    int? httpPort,
    int? socksPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    if (httpPort != null) {
      _settings.httpPort = httpPort;
    }

    if (socksPort != null) {
      _settings.socksPort = socksPort;
    }

    if (dnsLocalPort != null) {
      _settings.dnsLocalPort = dnsLocalPort;
    }

    if (dnsRemoteAddress != null) {
      _settings.dnsRemoteAddress = dnsRemoteAddress;
    }

    if (httpPort != null || socksPort != null || dnsLocalPort != null || dnsRemoteAddress != null) {
      await XinlakeTunnel.updateSettings(
        httpPort: httpPort,
        socksPort: socksPort,
        dnsLocalPort: dnsLocalPort,
        dnsRemoteAddress: dnsRemoteAddress,
      );
      await _settings.save();
    }
  }

  Future<void> _saveServerState() async {
    bool save = false;

    if (_settings.serverSelId != serverState.currentServer?.id) {
      _settings.serverSelId = serverState.currentServer?.id;
      save = true;

      // update vpn server
      final shadowsocks = serverState.currentServer;
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

    if (_settings.sortModeIndex != serverState.sortMode.index) {
      _settings.sortModeIndex = serverState.sortMode.index;
      save = true;
    }

    if (save) {
      await _settings.save();
    }
  }

  Future<void> _saveTheme() async {
    _settings.themeModeIndex = onThemeMode.value.index;
    await _settings.save();
  }

  /// single instance, use `instance` property, call `initialize()` first
  ///
  SettingManager._constructor({
    required Setting setting,
    required Shadowsocks? currentServer,
  })  : _settings = setting,
        serverState = ServerState(
          currentServer: currentServer,
          serverCount: ServerManager.instance.servers.length,
          sortMode: ServerSortMode.values[setting.sortModeIndex],
        ),
        onThemeMode = ValueNotifier(
          ThemeMode.values[setting.themeModeIndex],
        ) {
    serverState.addListener(() async => await _saveServerState());
    onThemeMode.addListener(() async => await _saveTheme());
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
