/*
  Xinlake Liu
  2022-04-12

  - Network setting changes are not saved until exit
  
  - When using the From autovalidateMode parameter, 
  its TextFormField does not trigger initial validation
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_text/validator.dart';

import '../models/server_manager.dart';
import '../models/setting_manager.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  static const route = "/home/setting";
  static const title = "Settings";

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  final _servers = ServerManager.instance;
  final _setting = SettingManager.instance;

  int? _httpPort;
  int? _socksPort;
  int? _dnsLocalPort;
  String? _dnsRemoteAddress;

  Widget _buildNetworkSettings() {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.only(top: 8, bottom: 4),
    );

    return Form(
      onWillPop: () async {
        await _setting.updateTunnelSetting(
          httpPort: _httpPort,
          socksPort: _socksPort,
          dnsLocalPort: _dnsLocalPort,
          dnsRemoteAddress: _dnsRemoteAddress,
        );

        return true;
      },
      child: Builder(builder: (context) {
        // settings for Android
        if (Platform.isAndroid) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      decoration: inputDecoration.copyWith(labelText: "Socks Port"),
                      keyboardType: TextInputType.number,
                      initialValue: "${_setting.socksPort}",
                      validator: (value) {
                        if (value != null) {
                          final port = Validator.getPortNumber(value);
                          if (port != null) {
                            _socksPort = port;
                            return null;
                          }
                        }
                        return "Invalid port number";
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      decoration: inputDecoration.copyWith(labelText: "Local DNS Port"),
                      keyboardType: TextInputType.number,
                      initialValue: "${_setting.dnsLocalPort}",
                      validator: (value) {
                        if (value != null) {
                          final port = Validator.getPortNumber(value);
                          if (port != null) {
                            _dnsLocalPort = port;
                            return null;
                          }
                        }
                        return "Invalid port number";
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // remote dns address
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                decoration: inputDecoration.copyWith(labelText: "Remote DNS Address"),
                keyboardType: TextInputType.url,
                initialValue: _setting.dnsRemoteAddress,
                validator: (value) {
                  if ((value != null && Validator.isURL(value))) {
                    _dnsRemoteAddress = value;
                    return null;
                  }
                  return "Invalid url";
                },
              ),
            ],
          );
        }

        // settings for Windows
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: inputDecoration.copyWith(labelText: "Http Proxy Port"),
                    keyboardType: TextInputType.number,
                    initialValue: "${_setting.httpPort}",
                    validator: (value) {
                      if (value != null) {
                        final port = Validator.getPortNumber(value);
                        if (port != null) {
                          _httpPort = port;
                          return null;
                        }
                      }
                      return "Invalid port number";
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: inputDecoration.copyWith(labelText: "Socks Port"),
                    keyboardType: TextInputType.number,
                    initialValue: "${_setting.socksPort}",
                    validator: (value) {
                      if (value != null) {
                        final port = Validator.getPortNumber(value);
                        if (port != null) {
                          _socksPort = port;
                          return null;
                        }
                      }
                      return "Invalid port number";
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildThemeSetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ThemeMode.values.map((theme) {
        final String name;
        switch (theme) {
          case ThemeMode.system:
            name = "System";
            break;
          case ThemeMode.light:
            name = "Light";
            break;
          case ThemeMode.dark:
            name = "Dark";
            break;
        }
        return Column(
          children: <Widget>[
            Text(name),
            Radio<ThemeMode>(
              value: theme,
              groupValue: _setting.onThemeMode.value,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    // have to refresh radio state
                    _setting.onThemeMode.value = value;
                  });
                }
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDebug() {
    return Row(
      children: [
        const Icon(Icons.code),
        TextButton(
          onPressed: () async {
            await _servers.generateRandom();
          },
          child: const Text("Generate Shadowsocks"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(SettingPage.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        child: Column(
          children: <Widget>[
            _buildThemeSetting(),
            const Divider(height: 20),
            _buildNetworkSettings(),
            const SizedBox(height: 20),
            _buildDebug(),
          ],
        ),
      ),
    );
  }
}
