/*
  Xinlake Liu
  2022-02-28

  - language
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_tunnel/xinlake_tunnel.dart';

import 'models/server_manager.dart';
import 'models/setting.dart';
import 'models/setting_manager.dart';
import 'models/shadowsocks.dart';
import 'pages/about_page.dart';
import 'pages/encrypt_list.dart';
import 'pages/home_page.dart';
import 'pages/setting_page.dart';
import 'pages/shadowsocks_detail.dart';
import 'pages/sorry_page.dart';

Future<bool> _initData() async {
  // init directory
  final appDir = await XinPlatform.getAppDir();
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

  // init tunnel
  await XinlakeTunnel.updateSettings(
    httpPort: settings.httpPort,
    socksPort: settings.socksPort,
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

  static const title = "Private Channel";
  final bool initSuccess;

  @override
  Widget build(BuildContext context) {
    final _setting = SettingManager.instance;

    return ValueListenableBuilder(
      valueListenable: _setting.onThemeMode,
      builder: (BuildContext context, ThemeMode value, Widget? child) {
        return MaterialApp(
          title: title,
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
          initialRoute: initSuccess ? HomePage.route : SorryPage.route,
          routes: {
            SorryPage.route: (context) => const SorryPage(),
            HomePage.route: (context) => const HomePage(),
            AboutPage.route: (context) => const AboutPage(),
            SettingPage.route: (context) => const SettingPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == ShadowsocksDetailPage.route) {
              final shadowsocks = settings.arguments as Shadowsocks;
              return MaterialPageRoute(
                builder: (context) => ShadowsocksDetailPage(shadowsocks),
              );
            } else if (settings.name == EncryptListPage.route) {
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
