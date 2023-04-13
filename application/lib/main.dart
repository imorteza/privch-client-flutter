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
import 'models/shadowsocks/shadowsocks07.dart';
import 'pages/about_page.dart';
import 'pages/encrypt_list.dart';
import 'pages/home_page.dart';
import 'pages/servers_page.dart';
import 'pages/setting_page.dart';
import 'pages/shadowsocks_detail.dart';
import 'pages/sorry_page.dart';

Future<bool> _initData() async {
  final xPlatform = XinPlatform();

  // init directory
  final appDir = await xPlatform.getAppDir();
  if (appDir == null) {
    return false;
  }

  // init database
  Hive.init(appDir.endsWith(Platform.pathSeparator)
      ? "${appDir}database"
      : "$appDir${Platform.pathSeparator}database");
  Hive.registerAdapter(ShadowsocksAdapter());
  Hive.registerAdapter(SettingAdapter());

  await ServerManager.initialize();
  await SettingManager.initialize();
  final settings = SettingManager.instance;

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
  static const title = "Private Channel";

  const PrivChApp(
    this.initSuccess, {
    Key? key,
  }) : super(key: key);

  final bool initSuccess;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SettingManager.instance.onThemeMode,
      builder: (BuildContext context, ThemeMode value, Widget? child) {
        return MaterialApp(
          title: title,
          // themes
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.light,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          themeMode: value,
          debugShowCheckedModeBanner: false,
          // routers
          initialRoute: initSuccess
              ? ServerManager.instance.servers.isNotEmpty
                  ? HomePage.route
                  : ServersPage.route
              : SorryPage.route,
          routes: {
            SorryPage.route: (context) => const SorryPage(),
            HomePage.route: (context) => const HomePage(),
            ServersPage.route: (context) => const ServersPage(),
            AboutPage.route: (context) => const AboutPage(),
            SettingPage.route: (context) => const SettingPage(),
          },
          onGenerateRoute: (route) {
            if (route.name == ShadowsocksDetailPage.route) {
              final arguments = route.arguments as ShadowsocksDetailArguments;
              return MaterialPageRoute(
                builder: (context) => ShadowsocksDetailPage(arguments),
              );
            } else if (route.name == EncryptListPage.route) {
              final encrypt = route.arguments as String;
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
