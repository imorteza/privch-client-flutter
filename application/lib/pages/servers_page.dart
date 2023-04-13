/*
  Xinlake Liu
  2022-04-17
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

import '../models/content.dart';
import '../models/server_manager.dart';
import '../models/setting_manager.dart';
import '../models/shadowsocks/shadowsocks07.dart';
import '../models/status.dart';
import 'shadowsocks_detail.dart';
import 'widgets/service_panel.dart';
import 'widgets/shadowsocks_list.dart';

class ServersPage extends StatefulWidget {
  static const route = "/home/servers";
  static const title = "Server List";

  const ServersPage({Key? key}) : super(key: key);

  @override
  State<ServersPage> createState() => _HomeState();
}

class _HomeState extends State<ServersPage> {
  final xPlatform = XinPlatform();
  final _servers = ServerManager.instance;
  final _settings = SettingManager.instance;

  late final _actionList = [
    Platform.isWindows
        ? AppAction(
            icon: Icons.screen_search_desktop_outlined,
            description: "Scan Screen ...",
            action: _importScreen,
          )
        : AppAction(
            icon: Icons.image,
            description: "Scan QR code ...",
            action: _importCamera,
          ),
    AppAction(
      icon: Icons.qr_code_scanner,
      description: "Import from image ...",
      action: _importImage,
    ),
    AppAction(
      icon: Icons.add_box,
      description: "Create new ...",
      action: _createServer,
    ),
  ];

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
    final images = await xPlatform.pickFile(
      multiSelection: true,
      mimeTypes: "image/*",
      cacheDir: XinAndroidAppDir.externalFiles,
      typesDescription: "Images",
    );
    if (images == null || images.isEmpty) {
      return;
    }

    final codeList = await XinQrcode.readImage(images.map((file) => file.path!).toList());
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

    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
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
      arguments: ShadowsocksDetailArguments(true, shadowsocks),
    );

    if (shadowsocks.isValid) {
      // add server to db first, otherwise it will causes the "not in the box" exception
      _servers.add(shadowsocks);
      shadowsocks.save();
    }
  }

  Widget _buildSortMenu() {
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
            case ServerSortMode.updated:
              sortBy = "Updated";
              break;
            case ServerSortMode.name:
              sortBy = "Name";
              break;
            case ServerSortMode.encrypt:
              sortBy = "Encrypt";
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

  Widget _buildAddMenu() {
    final iconColor = Theme.of(context).colorScheme.secondary;
    return PopupMenuButton<int>(
      icon: const Icon(Icons.add_circle_outline),
      onSelected: (index) async {
        final action = _actionList[index];
        action.action.call();
      },
      itemBuilder: (context) {
        return List<PopupMenuItem<int>>.generate(_actionList.length, (index) {
          final action = _actionList[index];
          return PopupMenuItem<int>(
            value: index,
            child: Row(
              children: [
                Icon(action.icon, color: iconColor),
                const SizedBox(width: 10),
                Text(action.description!),
              ],
            ),
          );
        });
      },
    );
  }

  // the content when the list is  empty
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
              children: _actionList.map((action) {
                return ElevatedButton(
                  onPressed: action.action,
                  child: Text(action.description!),
                );
              }).toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(ServersPage.title),
        actions: [
          _buildSortMenu(),
          _buildAddMenu(),
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
            child: ServicePanel(
              onLongPress: () => Navigator.pop(context),
            ),
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
    );
  }
}
