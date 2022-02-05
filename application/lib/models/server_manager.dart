import 'package:hive/hive.dart';

import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/shadowsocks.dart';

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
      if (!update) {
        return;
      }
    }

    // put and notify count changed
    await _serverBox.put(shadowsocks.id, shadowsocks);
    _updateCount();
  }

  Future<void> addAll(
    List<Shadowsocks> ssList, {
    bool Function(Shadowsocks shadowsocks)? onUpdate,
  }) async {
    for (var shadowsocks in ssList) {
      if (_serverBox.containsKey(shadowsocks.id)) {
        final update = onUpdate?.call(shadowsocks) ?? true;
        if (!update) {
          continue;
        }
      }

      await _serverBox.put(shadowsocks.id, shadowsocks);
    }

    // notify count changed
    _updateCount();
  }

  Future<bool> delete(Shadowsocks shadowsocks) async {
    await _serverBox.delete(shadowsocks.id);

    // notify count changed
    _updateCount();
    return true;
  }

  /// debug only
  Future<void> generateRandom({int count = 5}) async {
    while (--count > 0) {
      final ss = Shadowsocks.createRandom();
      await _serverBox.put(ss.id, ss);
    }

    _updateCount();
  }

  void _updateCount() {
    final newValue = SettingManager.instance.onServerState.value.copyWith(
      serverCount: _serverBox.length,
    );
    SettingManager.instance.onServerState.value = newValue;
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
