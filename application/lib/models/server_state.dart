/// shadowsocks sort methods
enum ServerSortMode { modified, address, name }

/// info about the server data changing
/// * 2021-12-07
class ServerState {
  final int serverCount;
  final String? serverSelId;
  final ServerSortMode sortMode;

  ServerState({
    required this.serverCount,
    required this.serverSelId,
    required this.sortMode,
  });

  ServerState copyWith({
    int? serverCount,
    String? serverSelId,
    ServerSortMode? sortMode,
  }) =>
      ServerState(
        serverCount: serverCount ?? this.serverCount,
        serverSelId: serverSelId ?? this.serverSelId,
        sortMode: sortMode ?? this.sortMode,
      );

  @override
  bool operator ==(other) {
    return other is ServerState &&
        other.serverCount == serverCount &&
        other.serverSelId == serverSelId &&
        other.sortMode == sortMode;
  }

  @override
  int get hashCode => Object.hash(serverCount, serverSelId, sortMode);
}
