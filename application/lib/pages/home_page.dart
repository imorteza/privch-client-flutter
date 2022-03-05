import 'dart:io';

import 'package:flutter/material.dart';
import 'package:privch/pages/setting_page.dart';
import 'package:privch/pages/shadowsocks_detail.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

import 'package:privch/models/server_manager.dart';
import 'package:privch/models/server_state.dart';
import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/shadowsocks.dart';
import 'package:privch/pages/widgets/shadowsocks_list.dart';
import 'package:privch/pages/widgets/service_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  static const route = "/home";
  final String title;

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _servers = ServerManager.instance;
  final _setting = SettingManager.instance;

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
    // TODO: refresh widget when only date changed
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

      // TODO: refresh widget when only date changed
    );

    final added = ssList.length - updated;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$added ${added > 1 ? 'servers' : 'server'} added"),
          ],
        ),
      ),
    );
  }

  Future<void> _createServer() async {
    final shadowsocks = Shadowsocks.createDefault();
    final checked = await Navigator.pushNamed(
      context,
      ShadowsocksDetailPage.route,
      arguments: shadowsocks,
    ) as bool?;

    if (checked != null && checked) {
      // add server to db first, otherwise it will causes the "not in the box" exception
      _servers.add(shadowsocks);
      shadowsocks.save();
    }
  }

  Widget _buildSortButton() {
    return PopupMenuButton<ServerSortMode>(
      onSelected: (value) {
        final newValue = _setting.onServerState.value.copyWith(sortMode: value);
        _setting.onServerState.value = newValue;
      },
      icon: const Icon(Icons.sort),
      itemBuilder: (context) {
        return ServerSortMode.values.map((item) {
          final bool selected = (item == _setting.onServerState.value.sortMode);
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
          // const PopupMenuItem<int>(
          //   enabled: false,
          //   height: 2,
          //   child: Divider(),
          // ),
          // PopupMenuItem<int>(
          //   value: 3,
          //   child: Row(
          //     children: [
          //       Icon(Icons.settings, color: iconColor),
          //       const SizedBox(width: 10),
          //       const Text("Settings"),
          //     ],
          //   ),
          // ),
        ];
      },
    );
  }

  Widget _buildDrawerItem(IconData iconData, String title, void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(iconData),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            // TODO: header
            // const Divider(height: 10),
            _buildDrawerItem(
              Icons.settings,
              "Setting",
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingPage.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  // the content when the list is empty
  Widget _buildEmpty() {
    final themeData = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Nothing here",
          style: themeData.textTheme.headline5,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            "Add servers now ?",
            style: themeData.textTheme.caption,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _buildSortButton(),
          _buildMoreMenu(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ShadowsocksList(
              empty: _buildEmpty(),
            ),
          ),
          const ServiceButton(),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
