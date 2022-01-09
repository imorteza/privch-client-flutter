import 'package:hive/hive.dart';

import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/shadowsocks.dart';

/// server data manager
class ServerManager {
  final Box<Shadowsocks> _serverBox;

  Iterable<Shadowsocks> get servers => _serverBox.values;

  Future<void> add(Shadowsocks shadowsocks) async {
    await _serverBox.add(shadowsocks);

    // notify count changed
    _updateCount();
  }

  Future<void> addAll(List<Shadowsocks> ssList) async {
    await _serverBox.addAll(ssList);

    // notify count changed
    _updateCount();
  }

  Future<bool> delete(Shadowsocks shadowsocks) async {
    try {
      final key = _serverBox.keys.singleWhere((key) {
        return shadowsocks == _serverBox.get(key);
      });
      await _serverBox.delete(key);
    } catch (exception) {
      return false;
    }

    // notify count changed
    _updateCount();
    return true;
  }

  /// debug only
  Future<void> generateRandom({int count = 15}) async {
    while (--count > 0) {
      await _serverBox.add(Shadowsocks.createRandom());
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
