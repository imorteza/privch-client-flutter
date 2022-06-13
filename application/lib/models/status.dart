/*
  Xinlake Liu
  2022-04-12
 */

import 'package:flutter/foundation.dart';

import 'shadowsocks/shadowsocks07.dart';

/// shadowsocks sort methods
enum ServerSortMode { modified, address, name }

class Status extends ChangeNotifier {
  Shadowsocks? _currentServer;
  ServerSortMode _sortMode;
  int _serverCount;

  Status({
    Shadowsocks? currentServer,
    required ServerSortMode sortMode,
    required int serverCount,
  })  : _currentServer = currentServer,
        _sortMode = sortMode,
        _serverCount = serverCount;

  Shadowsocks? get currentServer => _currentServer;
  ServerSortMode get sortMode => _sortMode;
  int get serverCount => _serverCount;

  set currentServer(Shadowsocks? value) {
    if (_currentServer != value) {
      _currentServer = value;
      notifyListeners();
    }
  }

  set sortMode(ServerSortMode value) {
    if (_sortMode != value) {
      _sortMode = value;
      notifyListeners();
    }
  }

  set serverCount(int value) {
    if (_serverCount != value) {
      _serverCount = value;
      notifyListeners();
    }
  }

  void forceNotify() => notifyListeners();

  @override
  bool operator ==(other) {
    return other is Status &&
        other.currentServer == _currentServer &&
        other.sortMode == _sortMode &&
        other.serverCount == _serverCount;
  }

  @override
  int get hashCode => Object.hash(_currentServer, _sortMode, _serverCount);
}
