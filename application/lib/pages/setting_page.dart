import 'dart:io';

import 'package:flutter/material.dart';
import 'package:privch/main.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_text/validator.dart';

import 'package:privch/global.dart';
import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/server_manager.dart';

/// save data when press back
/// * 2022-02
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
  final _formKey = GlobalKey<FormState>();

  int? _httpPort;
  int? _socksPort;
  int? _dnsLocalPort;
  String? _dnsRemoteAddress;

  Widget _buildNetworkSettings() {
    const inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.only(top: 8, bottom: 4),
    );

    return Form(
      key: _formKey,
      onWillPop: () async {
        _formKey.currentState?.save();
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
                      decoration: inputDecoration.copyWith(labelText: "Socks Port"),
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: TextInputType.number,
                      initialValue: "${_setting.socksPort}",
                      validator: (value) {
                        if (value != null) {
                          if (Validator.getPortNumber(value) != null) {
                            return null;
                          }
                        }
                        return "Invalid port number";
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _socksPort = int.parse(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: inputDecoration.copyWith(labelText: "Local DNS Port"),
                      autovalidateMode: AutovalidateMode.always,
                      keyboardType: TextInputType.number,
                      initialValue: "${_setting.dnsLocalPort}",
                      validator: (value) {
                        if (value != null) {
                          if (Validator.getPortNumber(value) != null) {
                            return null;
                          }
                        }
                        return "Invalid port number";
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _dnsLocalPort = int.parse(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // remote dns address
              TextFormField(
                decoration: inputDecoration.copyWith(labelText: "Remote DNS Address"),
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.url,
                initialValue: _setting.dnsRemoteAddress,
                validator: (value) {
                  if ((value != null && Validator.isURL(value))) {
                    return null;
                  }
                  return "Invalid url";
                },
                onSaved: (value) {
                  if (value != null) {
                    _dnsRemoteAddress = value;
                  }
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
                    decoration: inputDecoration.copyWith(labelText: "Http Proxy Port"),
                    autovalidateMode: AutovalidateMode.always,
                    keyboardType: TextInputType.number,
                    initialValue: "${_setting.httpPort}",
                    validator: (value) {
                      if ((value != null && Validator.getPortNumber(value) != null)) {
                        return null;
                      }
                      return "Invalid port number";
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _httpPort = int.parse(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: inputDecoration.copyWith(labelText: "Socks Port"),
                    autovalidateMode: AutovalidateMode.always,
                    keyboardType: TextInputType.number,
                    initialValue: "${_setting.socksPort}",
                    validator: (value) {
                      if ((value != null && Validator.getPortNumber(value) != null)) {
                        return null;
                      }
                      return "Invalid port number";
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _socksPort = int.parse(value);
                      }
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

  Widget _buildAbout() {
    return IconButton(
      onPressed: () async {
        final verInfo = await XinPlatform.getAppVersion();

        showDialog(
          context: context,
          builder: (context) {
            final style = Theme.of(context).textTheme.caption;
            final content = <TableRow>[];

            if (verInfo != null) {
              content.add(TableRow(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "version: ",
                      style: style,
                    ),
                  ),
                  Text(verInfo.version),
                ],
              ));

              content.add(TableRow(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "updated: ",
                      style: style,
                    ),
                  ),
                  Text(dateFormat.format(verInfo.updatedTime)),
                ],
              ));
            }

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Icon(Icons.security),
                  SizedBox(width: 10),
                  Text(PrivChApp.title),
                ],
              ),
              content: Table(
                textBaseline: TextBaseline.alphabetic,
                defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: content,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(MaterialLocalizations.of(context).viewLicensesButtonLabel),
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationVersion: verInfo?.version,
                      applicationIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.security, size: 40),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              scrollable: true,
            );
          },
        );
      },
      icon: const Icon(Icons.security),
    );
  }

  Widget _buildBanner(String title) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textScaleFactor: 1.2,
            ),
          ],
        ),
        const Divider(height: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(SettingPage.title),
        actions: [_buildAbout()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        child: Column(
          children: <Widget>[
            // theme settings
            _buildThemeSetting(),
            // network settings
            const SizedBox(height: 20),
            _buildBanner("NETWORKING"),
            _buildNetworkSettings(),
            // develop debug only
            const SizedBox(height: 20),
            _buildDebug(),
          ],
        ),
      ),
    );
  }
}
