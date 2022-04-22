import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_interface/window_interface.dart';
import 'package:xinlake_text/readable.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

import '../../models/server_manager.dart';
import '../models/setting_manager.dart';
import 'about_page.dart';
import 'servers_page.dart';
import 'setting_page.dart';
import 'widgets/ripple.dart';
import 'widgets/traffic_charts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const route = "/home";
  static const title = "Private Channel";

  @override
  State<StatefulWidget> createState() => _AutoState();
}

Future<bool> _checkConnection(Object? object) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 7)
    ..badCertificateCallback = (certificate, host, port) => true;

  // http status
  var statusCode = 404;

  try {
    final uri = Uri.parse("https://google.com");
    HttpClientRequest request = await client.getUrl(uri);
    // Optionally set up headers...
    // Optionally write to the request object...
    HttpClientResponse response = await request.close();
    statusCode = response.statusCode;
    response.drain();
  } catch (exception) {
    // ignored
  }

  // close client
  client.close();

  switch (statusCode) {
    case 200:
    case 204:
    case 301:
    case 429:
      return true;
    default:
      return false;
  }
}

class _AutoState extends State<HomePage> {
  final _servers = ServerManager.instance;
  final _settings = SettingManager.instance;

  final _rxTrace = List.generate(30, (index) => 0);
  final _txTrace = List.generate(30, (index) => 0);
  final _onTrafficTxRxBytesPerSecond = ValueNotifier<List<int>?>(null);

  var _processing = false;
  var _updateTrafficBytes = true;

  Future<void> _smartConnect() async {
    setState(() => _processing = true);

    // check current server
    final currentServer = _settings.status.currentServer;
    if (currentServer != null) {
      await XinlakeTunnel.connectTunnel(
        currentServer.hashCode,
        currentServer.port,
        currentServer.address,
        currentServer.password,
        currentServer.encrypt,
      );
      await Future.delayed(const Duration(milliseconds: 150));

      // check connection in a isolate
      final ready = await compute(_checkConnection, null);
      if (ready) {
        setState(() => _processing = false);
        return;
      }
    }

    // find the next server
    var connected = false;
    for (final shadowsocks in _servers.servers) {
      _settings.status.currentServer = shadowsocks;
      await Future.delayed(const Duration(milliseconds: 150));

      // check connection in a isolate
      connected = await compute(_checkConnection, null);
      if (connected) {
        break;
      }
    }

    setState(() => _processing = false);
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

  Widget _buildTunnelButton() {
    const buttonSize = 100.0;
    const progressSize = 170.0;
    const rippleRadius = 50.0;

    final colorSecondary = Theme.of(context).colorScheme.secondary;
    final colorBackground = Theme.of(context).colorScheme.background;

    // progress
    if (_processing) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: progressSize,
            height: progressSize,
            child: CircularProgressIndicator(),
          ),
          Icon(
            Icons.sync,
            color: colorBackground,
            size: buttonSize,
          ),
        ],
      );
    }

    // button
    return ValueListenableBuilder<int>(
      valueListenable: XinlakeTunnel.onState,
      builder: (BuildContext context, int tunState, Widget? child) {
        if (tunState == XinlakeTunnel.stateConnected) {
          // connected, icon
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border.all(color: colorBackground),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                XinlakeTunnel.stopTunnel();
              },
              iconSize: buttonSize,
              icon: Icon(
                Icons.gpp_good,
                color: colorSecondary,
              ),
            ),
          );
        } else if (tunState == XinlakeTunnel.stateStopped) {
          // stopped, small icon
          return RippleAnimation(
            color: colorBackground,
            minRadius: rippleRadius,
            duration: const Duration(seconds: 3),
            child: IconButton(
              onPressed: _smartConnect,
              iconSize: buttonSize,
              icon: const Icon(Icons.security),
            ),
          );
        } else {
          // connecting/stopping, middle icon
          return (tunState == XinlakeTunnel.stateConnecting)
              ? const Icon(Icons.gpp_good, size: buttonSize)
              : const Icon(Icons.security, size: buttonSize);
        }
      },
    );
  }

  Widget _buildTrafficChart() {
    const fontIconSize = 14.0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final rxColors = [primaryColor, primaryColor.withOpacity(0.02)];
    final txColors = [Colors.grey, Colors.grey.withOpacity(0.1)];

    // text style
    final styleMax = TextStyle(color: Theme.of(context).hintColor);
    final styleSpeed = TextStyle(color: primaryColor);

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

        return Column(
          children: [
            AspectRatio(
              aspectRatio: 2.6,
              child: TrafficChart(
                rxMax: rxMax,
                txMax: txMax,
                rxTrace: _rxTrace,
                txTrace: _txTrace,
                rxColors: rxColors,
                txColors: txColors,
                rxBarWidth: 3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        // no data
                        ? const Icon(
                            Icons.arrow_upward,
                            size: fontIconSize,
                          )
                        : Text(
                            Readable.formatSize(txBytes),
                            style: styleSpeed,
                          ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        ? const Icon(
                            Icons.keyboard_double_arrow_up,
                            size: fontIconSize,
                          )
                        : Text(
                            Readable.formatSize(txMax),
                            style: styleMax,
                          ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        // no data
                        ? const Icon(
                            Icons.arrow_downward,
                            size: fontIconSize,
                          )
                        : Text(
                            Readable.formatSize(rxBytes),
                            style: styleSpeed,
                          ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: trafficTxRx == null
                        // no data
                        ? const Icon(
                            Icons.keyboard_double_arrow_down,
                            size: fontIconSize,
                          )
                        : Text(
                            Readable.formatSize(rxMax),
                            style: styleMax,
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

  Widget _buildStatus() {
    return InkWell(
      onTap: _processing
          ? null
          : () {
              Navigator.pushNamed(context, ServersPage.route);
            },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              Icons.storage,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedBuilder(
                animation: _settings.status,
                builder: (context, child) {
                  return Row(
                    children: [
                      Text(
                        "${_servers.servers.length}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _settings.status.currentServer?.name ?? "Server Not Set",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: _processing ? Colors.grey : Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    Widget drawerItem(IconData iconData, String title, void Function() onTap) => InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(iconData),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );

    return Drawer(
      child: Column(
        children: [
          // header
          _buildDrawerHeader(),
          const Divider(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  drawerItem(
                    Icons.public,
                    "Auto Connect",
                    () {
                      Navigator.pop(context);
                    },
                  ),
                  drawerItem(
                    Icons.settings,
                    ServersPage.title,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ServersPage.route);
                    },
                  ),
                  drawerItem(
                    Icons.settings,
                    SettingPage.title,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, SettingPage.route);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, AboutPage.route);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 10),
        child: Row(
          children: [
            const Image(
              image: AssetImage('.assets/icon.png'),
              width: 40,
              height: 40,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Private ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const TextSpan(
                      text: "Channel",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(HomePage.title),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTrafficChart(),
          Expanded(
            child: Center(
              child: _buildTunnelButton(),
            ),
          ),
          const Divider(indent: 10, endIndent: 10, height: 1),
          _buildStatus(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initWindow();

    XinlakeTunnel.startListen();
    // restore state when reattached to engine
    XinlakeTunnel.updateState();

    if (Platform.isAndroid) {
      _syncTrafficBytes();
    }
  }

  @override
  void dispose() {
    _updateTrafficBytes = false;
    XinlakeTunnel.stopListen();

    // dispose window interface
    WindowInterface.stopListen();
    super.dispose();
  }

  Future<void> initWindow() async {
    // init window
    if (Platform.isWindows) {
      await WindowInterface.setWindowMinSize(400, 600);
      final placement = _settings.windowPlacement;
      if (placement.isValid) {
        await WindowInterface.setWindowPlacement(placement);
      }
      // listen window update
      WindowInterface.startListen(
        onPlacement: (value) async => await _settings.updateWindowPlacement(value),
      );
    }
  }
}
