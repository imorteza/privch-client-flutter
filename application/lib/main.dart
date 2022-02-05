/*
  TODO: language

  Xinlake Liu
  2022-01
 */

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:window_interface/window_interface.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

import 'package:privch/models/setting.dart';
import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/shadowsocks.dart';
import 'package:privch/models/server_manager.dart';
import 'package:privch/pages/sorry_page.dart';
import 'package:privch/pages/encrypt_list.dart';
import 'package:privch/pages/setting_page.dart';
import 'package:privch/pages/shadowsocks_detail.dart';
import 'package:privch/pages/home_page.dart';

Future<bool> _initData() async {
  // init directory
  final appDir = await XinlakePlatform.getAppDir();
  if (appDir == null) {
    return false;
  }

  // init database
  Hive.init(appDir.endsWith(Platform.pathSeparator)
      ? appDir + "database"
      : appDir + Platform.pathSeparator + "database");
  Hive.registerAdapter(ShadowsocksAdapter());
  Hive.registerAdapter(SettingAdapter());

  await ServerManager.initialize();
  await SettingManager.initialize();
  final settings = SettingManager.instance;

  // init window
  if (Platform.isWindows) {
    await WindowInterface.setWindowMinSize(400, 600);
    final placement = settings.windowPlacement();
    if (placement.isValid) {
      await WindowInterface.setWindowPlacement(placement);
    }
  }

  // init tunnel
  await XinlakeTunnel.updateSettings(
    proxyPort: settings.proxyPort,
    dnsLocalPort: settings.dnsLocalPort,
    dnsRemoteAddress: settings.dnsRemoteAddress,
  );

  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initSuccess = await _initData();
  runApp(PrivChApp(initSuccess));
}

class PrivChApp extends StatelessWidget {
  const PrivChApp(this.initSuccess, {Key? key}) : super(key: key);

  final bool initSuccess;

  @override
  Widget build(BuildContext context) {
    final _setting = SettingManager.instance;

    return ValueListenableBuilder(
      valueListenable: _setting.onThemeMode,
      builder: (BuildContext context, ThemeMode value, Widget? child) {
        return MaterialApp(
          title: 'Private Channel',
          // themes
          theme: ThemeData(
            primarySwatch: Colors.purple,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
          ),
          themeMode: value,
          // routers
          initialRoute: initSuccess ? "/home" : "/sorry",
          routes: {
            "/sorry": (context) => const SorryPage(),
            "/home": (context) => const HomePage(title: "PrivCh"),
            "/home/setting": (context) => const SettingPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == "/home/shadowsocks") {
              final shadowsocks = settings.arguments as Shadowsocks;
              return MaterialPageRoute(
                builder: (context) => ShadowsocksDetailPage(shadowsocks),
              );
            } else if (settings.name == "/home/shadowsocks/encrypt") {
              final encrypt = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => EncryptListPage(encrypt: encrypt),
              );
            } else {
              return null;
            }
          },
        );
      },
    );
  }
}
