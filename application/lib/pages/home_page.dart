/*
  Xinlake Liu
  2022-04-12
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_interface/window_interface.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

import '../models/server_manager.dart';
import '../models/setting_manager.dart';
import '../models/shadowsocks.dart';
import '../models/status.dart';
import '../pages/about_page.dart';
import '../pages/setting_page.dart';
import '../pages/shadowsocks_detail.dart';
import '../pages/widgets/service_panel.dart';
import '../pages/widgets/shadowsocks_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const route = "/home";
  static const title = "PrivCh";

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _servers = ServerManager.instance;
  final _settings = SettingManager.instance;

  Future<void> _importCamera() async {
    final qrcode = await XinQrcode.fromCamera(
      prefix: "ss://",
      playBeep: true,
    );
    if (qrcode == null) {
      return;
    }

    final shadowsocks = Shadowsocks.parserQrCode(qrcode);
    if (shadowsocks == null) {
      return;
    }

    await _servers.add(
      shadowsocks,
      onUpdate: () {
        // snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${shadowsocks.name} updated"),
              ],
            ),
          ),
        );
        return true;
      },
    );
  }

  Future<void> _importScreen() async {
    final codeList = await XinQrcode.readScreen();
    if (codeList == null || codeList.isEmpty) {
      return;
    }

    final ssList = <Shadowsocks>[];
    for (final qrcode in codeList) {
      final shadowsocks = Shadowsocks.parserQrCode(qrcode);
      if (shadowsocks != null) {
        ssList.add(shadowsocks);
      }
    }

    if (ssList.isNotEmpty) {
      _addList(ssList);
    }
  }

  Future<void> _importImage() async {
    final images = await XinPlatform.pickFiles(
      multiSelection: true,
      mimeType: "image/*",
      cacheDir: XinAndroidAppDir.externalFiles,
      filterName: "JPEG, PNG Images",
      filterPattern: "*.jpg; *.jpeg; *.png",
    );
    if (images == null || images.isEmpty) {
      return;
    }

    final codeList = await XinQrcode.readImage(images);
    if (codeList == null || codeList.isEmpty) {
      return;
    }

    final ssList = <Shadowsocks>[];
    for (final qrcode in codeList) {
      final shadowsocks = Shadowsocks.parserQrCode(qrcode);
      if (shadowsocks != null) {
        ssList.add(shadowsocks);
      }
    }

    if (ssList.isNotEmpty) {
      _addList(ssList);
    }
  }

  Future<void> _addList(List<Shadowsocks> ssList) async {
    var updated = 0;
    await _servers.addAll(
      ssList,
      onUpdate: (shadowsocks) {
        // snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${shadowsocks.name} updated"),
              ],
            ),
          ),
        );

        ++updated;
        return true;
      },
    );

    final added = ssList.length - updated;
    final servers = added > 1 ? 'servers' : 'server';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$added $servers added"),
          ],
        ),
      ),
    );
  }

  Future<void> _createServer() async {
    final shadowsocks = Shadowsocks.createDefault();
    await Navigator.pushNamed(
      context,
      ShadowsocksDetailPage.route,
      arguments: shadowsocks,
    );

    if (shadowsocks.isValid) {
      // add server to db first, otherwise it will causes the "not in the box" exception
      _servers.add(shadowsocks);
      shadowsocks.save();
    }
  }

  Widget _buildSortButton() {
    return PopupMenuButton<ServerSortMode>(
      onSelected: (value) {
        _settings.status.sortMode = value;
      },
      icon: const Icon(Icons.sort),
      itemBuilder: (context) {
        return ServerSortMode.values.map((item) {
          final bool selected = (item == _settings.status.sortMode);
          final String sortBy;
          switch (item) {
            case ServerSortMode.modified:
              sortBy = "Modified";
              break;
            case ServerSortMode.address:
              sortBy = "Address";
              break;
            case ServerSortMode.name:
              sortBy = "Name";
              break;
          }

          return PopupMenuItem<ServerSortMode>(
            value: item,
            child: Text(
              sortBy,
              style: selected ? TextStyle(color: Theme.of(context).colorScheme.secondary) : null,
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (index) async {
        switch (index) {
          case 0:
            Platform.isWindows ? await _importScreen() : await _importCamera();
            break;
          case 1:
            await _importImage();
            break;
          case 2:
            await _createServer();
            break;
        }
      },
      itemBuilder: (context) {
        final iconColor = Theme.of(context).colorScheme.secondary;
        return [
          PopupMenuItem<int>(
            value: 0,
            child: Platform.isWindows
                ? Row(
                    children: [
                      Icon(Icons.screen_search_desktop_outlined, color: iconColor),
                      const SizedBox(width: 10),
                      const Text("Scan Screen ..."),
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: iconColor),
                      const SizedBox(width: 10),
                      const Text("Scan QR code ..."),
                    ],
                  ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.image, color: iconColor),
                const SizedBox(width: 10),
                const Text("Import from image ..."),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.add_box, color: iconColor),
                const SizedBox(width: 10),
                const Text("Create new ..."),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          const Divider(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDrawerItem(
                    Icons.settings,
                    "Settings",
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

  Widget _buildDrawerItem(IconData iconData, String title, void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(iconData),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 20,
              ),
            ),
          ],
        ),
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

  // the content when the list is empty
  Widget _buildEmptyList() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Nothing here",
          style: TextStyle(
            fontSize: 26,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            "Add servers now ?",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Center(
          child: IntrinsicWidth(
            stepWidth: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // action buttons
              children: [
                Builder(builder: (context) {
                  if (Platform.isWindows) {
                    return ElevatedButton(
                      child: const Text("Scan Screen ..."),
                      onPressed: _importScreen,
                    );
                  }
                  return ElevatedButton(
                    child: const Text("Scan QR code ..."),
                    onPressed: _importCamera,
                  );
                }),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text("Import from image ..."),
                  onPressed: _importImage,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  child: const Text("Create new ..."),
                  onPressed: _createServer,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildEmptyPanel() {
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

  void disposeWindow() {
    WindowInterface.stopListen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: const Text(HomePage.title),
        actions: [
          _buildSortButton(),
          _buildMoreMenu(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ShadowsocksList(
              empty: _buildEmptyList(),
            ),
          ),
          AnimatedBuilder(
            animation: _settings.status,
            child: const ServicePanel(),
            builder: (context, servicePanel) {
              if (_settings.status.serverCount < 1) {
                // the empty panel also does not depend on the animation
                return _buildEmptyPanel();
              }

              return servicePanel!;
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  @override
  void initState() {
    super.initState();
    initWindow();
  }

  @override
  void dispose() {
    disposeWindow();
    super.dispose();
  }
}
