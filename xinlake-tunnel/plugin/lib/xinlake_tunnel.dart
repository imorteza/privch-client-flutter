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
  static StreamSubscription? _tunnelSubscription;

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

    _tunnelSubscription!.resume();
  }

  /// cancel the tunnel events subscription
  static void stopListen() {
    _tunnelSubscription?.cancel();
    _tunnelSubscription = null;
  }

  // method channel --------------------------------------------------------------------------------
  static const _methodChannel = MethodChannel('xinlake_tunnel_method');

  /// element 0: tx bytes, element 1: rx bytes
  static Future<List<int>?> getTrafficBytes() async {
    try {
      final trafficTxRx = await _methodChannel.invokeListMethod<int>("getTrafficBytes");
      return trafficTxRx;
    } catch (exception) {
      return null;
    }
  }

  static Future<void> connectTunnel(
    int serverId,
    int port,
    String address,
    String password,
    String encrypt,
  ) async {
    await _methodChannel.invokeMethod("connectTunnel", {
      "serverId": serverId,
      "port": port,
      "address": address,
      "password": password,
      "encrypt": encrypt,
    });
  }

  static Future<void> stopTunnel() async {
    await _methodChannel.invokeMethod("stopTunnel");
  }

  /// This must be called once before connectTunnel
  /// * [socksPort] local socks client listen port
  ///
  /// Android
  /// * [dnsLocalPort], [dnsRemoteAddress] dns settings
  ///
  /// Windows
  /// * [httpPort] local http proxy listen port
  ///
  /// [httpPort] parameter used on Windows only
  static Future<void> updateSettings({
    int? httpPort,
    int? socksPort,
    int? dnsLocalPort,
    String? dnsRemoteAddress,
  }) async {
    await _methodChannel.invokeMethod("updateSettings", {
      "httpPort": httpPort,
      "socksPort": socksPort,
      "dnsLocalPort": dnsLocalPort,
      "dnsRemoteAddress": dnsRemoteAddress,
    });
  }
}
