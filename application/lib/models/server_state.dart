import 'package:privch/models/shadowsocks.dart';

/// shadowsocks sort methods
enum ServerSortMode { modified, address, name }

/// info about the server data changing
/// * 2022-01-19
class ServerState {
  final Shadowsocks? currentServer;
  final ServerSortMode sortMode;
  final int serverCount;

  ServerState({
    required this.currentServer,
    required this.sortMode,
    required this.serverCount,
  });

  ServerState copyWith({
    Shadowsocks? currentServer,
    ServerSortMode? sortMode,
    int? serverCount,
  }) =>
      ServerState(
        currentServer: currentServer ?? this.currentServer,
        sortMode: sortMode ?? this.sortMode,
        serverCount: serverCount ?? this.serverCount,
      );

  @override
  bool operator ==(other) {
    return other is ServerState &&
        other.currentServer == currentServer &&
        other.sortMode == sortMode &&
        other.serverCount == serverCount;
  }

  @override
  int get hashCode => Object.hash(currentServer, sortMode, serverCount);
}
