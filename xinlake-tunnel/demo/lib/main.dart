import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xinlake_text/readable.dart';
import 'package:xinlake_text/validator.dart';

import 'package:xinlake_tunnel/xinlake_tunnel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _proxyPort = 1080;
  int _dnsLocalPort = 5450;
  String _dnsRemoteAddress = "8.8.8.8";

  final int _serverId = 100;
  int _port = 826;
  String _address = "141.95.0.26";
  String _password = "sF43Xt2gONqcgFX563";
  String _encrypt = "chacha20-ietf-poly1305";

  bool _update = true;
  final _onTrafficTxRx = ValueNotifier<List<int>?>(null);

  Future<void> _updateTraffic() async {
    while (_update) {
      for (int i = 0; i < 12; ++i) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_update) {
          return;
        }
      }

      final trafficTxRx = await XinlakeTunnel.getTrafficBytes();
      _onTrafficTxRx.value = trafficTxRx;
    }
  }

  Widget _buildState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(10),
            2: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("State"),
                ),
                const SizedBox(),
                ValueListenableBuilder<int>(
                  valueListenable: XinlakeTunnel.onState,
                  builder: (context, value, child) {
                    String state;
                    switch (value) {
                      case XinlakeTunnel.stateConnecting:
                        state = "Connecting";
                        break;
                      case XinlakeTunnel.stateConnected:
                        state = "Connected";
                        break;
                      case XinlakeTunnel.stateStopping:
                        state = "Stopping";
                        break;
                      case XinlakeTunnel.stateStopped:
                        state = "Stopped";
                        break;
                      default:
                        state = "Invalid";
                        break;
                    }
                    return Text(state);
                  },
                ),
              ],
            ),
            TableRow(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("Server Id"),
                ),
                const SizedBox(),
                ValueListenableBuilder<int?>(
                  valueListenable: XinlakeTunnel.onServerId,
                  builder: (context, value, child) {
                    return Text("${value ?? "Not Set"}");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartStop() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("port")),
                    initialValue: "$_port",
                    validator: (value) {
                      if (value != null) {
                        int? port = int.tryParse(value);
                        if (port != null && port > 0 && port < 65535) {
                          _port = port;
                          return null;
                        }
                      }
                      return "Invalid value";
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("address")),
                    initialValue: _address,
                    validator: (value) {
                      if (value != null && Validator.isURL(value)) {
                        _address = value;
                        return null;
                      }
                      return "Invalid value";
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("encrypt")),
                    initialValue: _encrypt,
                    validator: (value) {
                      if (value != null) {
                        _encrypt = value;
                        return null;
                      }
                      return "Invalid value";
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("password")),
                    initialValue: _password,
                    validator: (value) {
                      if (value != null) {
                        _password = value;
                        return null;
                      }
                      return "Invalid value";
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: XinlakeTunnel.onState,
              builder: (context, value, child) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (value == XinlakeTunnel.stateStopped)
                            ? () async => await XinlakeTunnel.connectTunnel(
                                _serverId, _port, _address, _password, _encrypt)
                            : null,
                        child: const Text("startShadowsocks"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (value == XinlakeTunnel.stateConnected)
                            ? () async => await XinlakeTunnel.stopTunnel()
                            : null,
                        child: const Text("stopService"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("Proxy port")),
                    initialValue: "$_proxyPort",
                    validator: (value) {
                      if (value != null) {
                        int? port = int.tryParse(value);
                        if (port != null && port > 0 && port < 65535) {
                          _proxyPort = port;
                          return null;
                        }
                      }
                      return "Invalid value";
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("Dns local port")),
                    initialValue: "$_dnsLocalPort",
                    validator: (value) {
                      if (value != null) {
                        int? port = int.tryParse(value);
                        if (port != null && port > 0 && port < 65535) {
                          _dnsLocalPort = port;
                          return null;
                        }
                      }
                      return "Invalid value";
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(label: Text("Dns remote address")),
                    initialValue: _dnsRemoteAddress,
                    validator: (value) {
                      if (value != null && Validator.isURL(value)) {
                        _dnsRemoteAddress = value;
                        return null;
                      }
                      return "Invalid value";
                    },
                  ),
                ),
              ],
            ),
            ValueListenableBuilder<int>(
              valueListenable: XinlakeTunnel.onState,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: (value == XinlakeTunnel.stateStopped)
                      ? () async => await XinlakeTunnel.updateSettings(
                            proxyPort: _proxyPort,
                            dnsLocalPort: _dnsLocalPort,
                            dnsRemoteAddress: _dnsRemoteAddress,
                          )
                      : null,
                  child: const Text("updateSettings"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraffic() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<List<int>?>(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.data_usage),
              SizedBox(width: 10),
              Text("NULL"),
            ],
          ),
          valueListenable: _onTrafficTxRx,
          builder: (context, value, child) {
            // empty
            if (value == null) {
              return child!;
            }

            return Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward),
                      Text(Readable.formatSize(value[0])),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward),
                      Text(Readable.formatSize(value[1])),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        errorColor: Colors.deepOrange,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('XinlakeTunnel Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildTraffic(),
              _buildState(),
              _buildSettings(),
              _buildStartStop(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    XinlakeTunnel.startListen();
    _updateTraffic();
  }

  @override
  void dispose() {
    _update = false;
    XinlakeTunnel.stopListen();
    super.dispose();
  }
}
