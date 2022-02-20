import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_text/readable.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

import 'package:privch/models/server_state.dart';
import 'package:privch/models/setting_manager.dart';
import 'package:privch/pages/widgets/traffic_charts.dart';

class ServiceButton extends StatefulWidget {
  const ServiceButton({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ServiceState();
}

class ServiceState extends State<ServiceButton> {
  // max trace points
  static const _maxTrace = 20;

  final _setting = SettingManager.instance;
  final _rxTrace = List.generate(_maxTrace, (index) => 0);
  final _txTrace = List.generate(_maxTrace, (index) => 0);

  final _onTrafficTxRxBytesPerSecond = ValueNotifier<List<int>?>(null);
  bool _updateTrafficBytes = true;

  Future<void> _onServiceButton() async {
    if (XinlakeTunnel.onState.value == XinlakeTunnel.stateConnected) {
      await XinlakeTunnel.stopTunnel();
    } else if (XinlakeTunnel.onState.value == XinlakeTunnel.stateStopped) {
      final shadowsocks = _setting.onServerState.value.currentServer;
      if (shadowsocks != null) {
        await XinlakeTunnel.connectTunnel(
          shadowsocks.hashCode,
          shadowsocks.port,
          shadowsocks.address,
          shadowsocks.password,
          shadowsocks.encrypt,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Select a server"),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _syncTrafficBytes() async {
    int lastRxBytes;
    int lastTxBytes;

    final currentTxRx = await XinlakeTunnel.getTrafficBytes();
    if (currentTxRx != null) {
      lastRxBytes = currentTxRx.elementAt(0);
      lastTxBytes = currentTxRx.elementAt(1);
    } else {
      lastRxBytes = 0;
      lastTxBytes = 0;
    }

    while (_updateTrafficBytes) {
      // 100 x 10 = 1 second
      for (int i = 0; i < 10; ++i) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_updateTrafficBytes) {
          return;
        }
      }

      final trafficTxRx = await XinlakeTunnel.getTrafficBytes();
      if (trafficTxRx != null) {
        _onTrafficTxRxBytesPerSecond.value = [
          trafficTxRx.elementAt(0) - lastRxBytes,
          trafficTxRx.elementAt(1) - lastTxBytes,
        ];

        lastRxBytes = trafficTxRx.elementAt(0);
        lastTxBytes = trafficTxRx.elementAt(1);
      }
    }
  }

  Widget _buildTunPanel() {
    const panelHeight = 55.0;

    const tunIconSmall = 40.0;
    const tunIconMiddle = 50.0;
    const tunIconBig = 60.0;
    const tunBoxSize = 100.0;

    return Card(
      elevation: 8.0,
      child: Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: tunIconMiddle,
          height: panelHeight,
          child: OverflowBox(
            maxHeight: tunBoxSize,
            maxWidth: tunBoxSize,
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder<int>(
              valueListenable: XinlakeTunnel.onState,
              builder: (BuildContext context, int tunState, Widget? child) {
                if (tunState == XinlakeTunnel.stateConnected) {
                  // connected, icon
                  return IconButton(
                    onPressed: _onServiceButton,
                    iconSize: tunIconBig,
                    icon: const Icon(Icons.health_and_safety),
                    color: Theme.of(context).colorScheme.secondary,
                  );
                } else if (tunState == XinlakeTunnel.stateStopped) {
                  // stopped, small icon
                  return OutlinedButton(
                    onPressed: _onServiceButton,
                    style: ButtonStyle(
                      side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
                        return BorderSide.none;
                      }),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return Colors.grey.withAlpha(33);
                      }),
                    ),
                    child: Icon(
                      Icons.security,
                      size: tunIconSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  );
                } else {
                  // connecting/stopping, middle icon
                  return (tunState == XinlakeTunnel.stateConnecting)
                      ? const Icon(Icons.health_and_safety, size: tunIconMiddle)
                      : const Icon(Icons.security, size: tunIconMiddle);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTunPanelChart() {
    const panelHeight = 55.0;

    const tunIconSmall = 40.0;
    const tunIconMiddle = 50.0;
    const tunIconBig = 60.0;
    const tunBoxSize = 100.0;

    return Card(
      elevation: 8.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background, traffic info
          _buildTrafficChart(panelHeight, tunIconMiddle),
          // front, button
          SizedBox(
            width: tunIconMiddle,
            height: panelHeight,
            child: OverflowBox(
              maxHeight: tunBoxSize,
              maxWidth: tunBoxSize,
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<int>(
                valueListenable: XinlakeTunnel.onState,
                builder: (BuildContext context, int tunState, Widget? child) {
                  if (tunState == XinlakeTunnel.stateConnected) {
                    // connected, icon
                    return IconButton(
                      onPressed: _onServiceButton,
                      iconSize: tunIconBig,
                      icon: const Icon(Icons.health_and_safety),
                      color: Theme.of(context).colorScheme.secondary,
                    );
                  } else if (tunState == XinlakeTunnel.stateStopped) {
                    // stopped, small icon
                    return OutlinedButton(
                      onPressed: _onServiceButton,
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
                          return BorderSide.none;
                        }),
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          return Colors.grey.withAlpha(33);
                        }),
                      ),
                      child: Icon(
                        Icons.security,
                        size: tunIconSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    );
                  } else {
                    // connecting/stopping, middle icon
                    return (tunState == XinlakeTunnel.stateConnecting)
                        ? const Icon(Icons.health_and_safety, size: tunIconMiddle)
                        : const Icon(Icons.security, size: tunIconMiddle);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficChart(double panelHeight, double iconSize) {
    return ValueListenableBuilder(
      valueListenable: _onTrafficTxRxBytesPerSecond,
      builder: (BuildContext context, List<int>? trafficTxRx, Widget? child) {
        // calc speed (bytes per second)
        final int rxBytes = trafficTxRx?.elementAt(0) ?? 0;
        final int txBytes = trafficTxRx?.elementAt(1) ?? 0;

        // queue speed
        _rxTrace.removeAt(0);
        _txTrace.removeAt(0);
        _rxTrace.add(rxBytes);
        _txTrace.add(txBytes);

        // calc max speed
        final rxMax = _rxTrace.reduce((value, element) => value > element ? value : element);
        final txMax = _txTrace.reduce((value, element) => value > element ? value : element);

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: panelHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TrafficChart(_rxTrace, rxMax, _txTrace, txMax),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        ? const Icon(Icons.arrow_circle_up)
                        : Column(
                            children: [
                              Text(
                                Readable.formatSize(txBytes),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                Readable.formatSize(txMax),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(width: iconSize),
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        ? const Icon(Icons.arrow_circle_down)
                        : Column(
                            children: [
                              Text(
                                Readable.formatSize(rxBytes),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                Readable.formatSize(rxMax),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ServerState>(
      valueListenable: _setting.onServerState,
      child: Platform.isAndroid ? _buildTunPanelChart() : _buildTunPanel(),
      builder: (BuildContext context, ServerState serverState, Widget? tunPanel) {
        // empty
        if (serverState.serverCount < 1 && serverState.currentServer == null) {
          final colorScheme = Theme.of(context).colorScheme;
          return Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RichText(
                  text: TextSpan(
                    text: 'Private',
                    style: TextStyle(color: colorScheme.secondary, fontSize: 16),
                    children: const <TextSpan>[
                      TextSpan(
                        text: ' Channel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        // button.
        return tunPanel!;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    XinlakeTunnel.startListen();
    if (Platform.isAndroid) {
      _syncTrafficBytes();
    }
  }

  @override
  void dispose() {
    _updateTrafficBytes = false;
    XinlakeTunnel.stopListen();
    super.dispose();
  }
}
