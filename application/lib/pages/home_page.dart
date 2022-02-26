import 'package:flutter/material.dart';
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _servers = ServerManager.instance;
  final _setting = SettingManager.instance;

  Future<void> _scanQrcode() async {
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

    final ssList = <Shadowsocks>[];
    final codeList = await XinQrcode.readImage(images);
    codeList?.forEach((element) {
      final shadowsocks = Shadowsocks.parserQrCode(element);
      if (shadowsocks != null) {
        ssList.add(shadowsocks);
      }
    });

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
      "/home/shadowsocks",
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
            await _scanQrcode();
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
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: iconColor),
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
            const SizedBox(height: 30),
            // TODO: header
            // const Divider(height: 10),
            _buildDrawerItem(
              Icons.settings,
              "Setting",
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/home/setting");
              },
            ),
          ],
        ),
      ),
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
              onScanQrcode: () async => await _scanQrcode(),
              onImportImage: () async => await _importImage(),
              onCreateServer: () async => await _createServer(),
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
