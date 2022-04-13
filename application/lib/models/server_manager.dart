/*
  Xinlake Liu
  2022-04-12

  - forceNotify is not a good practice
 */

import 'dart:async';

import 'package:hive/hive.dart';

import '../models/setting_manager.dart';
import '../models/shadowsocks.dart';

/// server data manager
class ServerManager {
  final Box<Shadowsocks> _serverBox;
  Iterable<Shadowsocks> get servers => _serverBox.values;

  /// get server by id
  Shadowsocks? getServer(String id) {
    return _serverBox.get(id);
  }

  Future<void> add(
    Shadowsocks shadowsocks, {
    bool Function()? onUpdate,
  }) async {
    if (_serverBox.containsKey(shadowsocks.id)) {
      final update = onUpdate?.call() ?? true;
      if (update) {
        await _serverBox.put(shadowsocks.id, shadowsocks);
        SettingManager.instance.status.forceNotify();
        return;
      }
    } else {
      // put and notify count changed
      await _serverBox.put(shadowsocks.id, shadowsocks);
      SettingManager.instance.status.serverCount = _serverBox.length;
    }
  }

  Future<void> addAll(
    List<Shadowsocks> ssList, {
    bool Function(Shadowsocks shadowsocks)? onUpdate,
  }) async {
    int added = 0;

    for (var shadowsocks in ssList) {
      if (_serverBox.containsKey(shadowsocks.id)) {
        final update = onUpdate?.call(shadowsocks) ?? true;
        if (update) {
          await _serverBox.put(shadowsocks.id, shadowsocks);
          SettingManager.instance.status.forceNotify();
        }
      } else {
        await _serverBox.put(shadowsocks.id, shadowsocks);
        ++added;
      }
    }

    // notify count changed
    if (added > 0) {
      SettingManager.instance.status.serverCount = _serverBox.length;
    }
  }

  Future<bool> delete(Shadowsocks shadowsocks) async {
    await _serverBox.delete(shadowsocks.id);

    // notify count changed
    SettingManager.instance.status.serverCount = _serverBox.length;
    return true;
  }

  /// debug only
  Future<void> generateRandom({int count = 5}) async {
    while (--count > 0) {
      final ss = Shadowsocks.createRandom();
      await _serverBox.put(ss.id, ss);
    }

    SettingManager.instance.status.serverCount = _serverBox.length;
  }

  /// single instance, use `instance` property. call `initialize()` first
  ///
  ServerManager._constructor({
    required Box<Shadowsocks> serverBox,
  }) : _serverBox = serverBox;

  static late final ServerManager _instance;
  static ServerManager get instance => _instance;

  /// load data and create instance
  static Future<void> initialize() async {
    Box<Shadowsocks> serverBox = await Hive.openBox("shadowsocks");

    _instance = ServerManager._constructor(
      serverBox: serverBox,
    );
  }
}
