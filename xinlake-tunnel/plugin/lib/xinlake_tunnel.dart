import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XinlakeTunnel {
  static const int stateConnecting = 1;
  static const int stateConnected = 2;
  static const int stateStopping = 3;
  static const int stateStopped = 4;

  static final ValueNotifier<int?> onServerId = ValueNotifier(null);
  static final ValueNotifier<int> onState = ValueNotifier(stateStopped);

  // platform event channel and subscription
  static const _eventChannel = EventChannel("xinlake_tunnel_event");
  static late final StreamSubscription _tunnelSubscription;

  /// subscript to tunnel events
  static void startListen() {
    _tunnelSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is! Map) {
        return;
      }

      // server id
      if (event.containsKey("serverId")) {
        try {
          onServerId.value = event["serverId"] as int?;
        } catch (exception) {
          // ignored
        }
      }

      // state
      if (event.containsKey("state")) {
        try {
          onState.value = event["state"] as int;
        } catch (exception) {
          // ignored
        }
      }
    });
  }

  /// cancel the tunnel events subscription
  static void stopListen() {
    _tunnelSubscription.cancel();
  }

  // method channel --------------------------------------------------------------------------------
  static const _methodChannel = MethodChannel('xinlake_tunnel_method');

  static Future<void> startShadowsocks(
    int serverId,
    int port,
    String address,
    String password,
    String encrypt,
  ) async {
    await _methodChannel.invokeMethod("startShadowsocks", {
      "serverId": serverId,
      "port": port,
      "address": address,
      "password": password,
      "encrypt": encrypt,
    });
  }

  static Future<void> stopService() async {
    await _methodChannel.invokeMethod("stopService");
  }

  static Future<void> updateSettings({
    int? proxyPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    await _methodChannel.invokeMethod("updateSettings", {
      "proxyPort": proxyPort,
      "dnsLocalPort": dnsLocalPort,
      "dnsRemoteAddress": dnsRemoteAddress,
    });
  }

  static Future<void> bindService(int proxyPort, int dnsLocalPort, String dnsRemoteAddress) async {
    await _methodChannel.invokeMethod("bindService", {
      "proxyPort": proxyPort,
      "dnsLocalPort": dnsLocalPort,
      "dnsRemoteAddress": dnsRemoteAddress,
    });
  }

  static Future<void> unbindService() async {
    await _methodChannel.invokeMethod("unbindService");
  }
}
