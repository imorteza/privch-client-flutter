/*
  Xinlake Liu
 */

import 'package:flutter/material.dart';

import '../../models/server_manager.dart';
import '../../models/setting_manager.dart';
import '../../models/shadowsocks/shadowsocks07.dart';
import '../../models/status.dart';
import '../../pages/shadowsocks_detail.dart';
import '../../pages/widgets/shadowsocks_widget.dart';

class ShadowsocksList extends StatefulWidget {
  const ShadowsocksList({
    Key? key,
    required this.empty,
  }) : super(key: key);

  final Widget empty;

  @override
  State<StatefulWidget> createState() => ShadowsocksListState();
}

class ShadowsocksListState extends State<ShadowsocksList> {
  final _servers = ServerManager.instance;
  final _settings = SettingManager.instance;

  void _onItemDetail(Shadowsocks shadowsocks) async {
    // navigate to shadowsocks details
    await Navigator.pushNamed(
      context,
      ShadowsocksDetailPage.route,
      arguments: ShadowsocksDetailArguments(false, shadowsocks),
    );
    // not have to, the editor page will validate data
    if (shadowsocks.isValid) {
      shadowsocks.save();
    }
  }

  void _onItemSelected(Shadowsocks shadowsocks) {
    _settings.status.currentServer = shadowsocks;
  }

  Future<void> _onItemRemove(Shadowsocks shadowsocks) async {
    // remove the server
    if (await _servers.delete(shadowsocks)) {
      // cancel remove
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          content: Text("${shadowsocks.name} removed"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () async {
              await _servers.add(shadowsocks);
            },
          ),
        ));
      }
    }
  }

  /// item left background on swipe
  Widget _buildItemBgLeft(Color colorBg, Color colorFg) {
    return Container(
      color: colorBg,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.edit,
            color: colorFg,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: colorFg,
          ),
        ],
      ),
    );
  }

  /// item right background on swipe
  Widget _buildItemBgRight(Color colorBg, Color colorFg) {
    return Container(
      color: colorBg,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.arrow_back,
            color: colorFg,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.delete,
            color: colorFg,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(bool even, Shadowsocks shadowsocks) {
    final colorPrimary = Theme.of(context).colorScheme.primary;
    final colorSecondary = Theme.of(context).colorScheme.secondary;
    final colorBg = Theme.of(context).hoverColor;

    return Dismissible(
      key: Key("${shadowsocks.hashCode}"),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.3,
        DismissDirection.endToStart: 0.7,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // delete server
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          _onItemDetail(shadowsocks);
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        _onItemRemove(shadowsocks);
      },
      background: _buildItemBgLeft(colorBg, colorSecondary),
      secondaryBackground: _buildItemBgRight(colorBg, colorSecondary),
      child: ShadowsocksWidget(
        onTap: () => _onItemSelected(shadowsocks),
        bg: even ? null : colorPrimary.withOpacity(0.05),
        shadowsocks: shadowsocks,
      ),
    );
  }

  // AnimatedBuilder is not a good idea
  void _onStatusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_settings.status.serverCount < 1) {
      return widget.empty;
    }

    final ssList = _servers.servers.toList();
    switch (_settings.status.sortMode) {
      case ServerSortMode.updated:
        ssList.sort((ss1, ss2) => -ss1.modified.compareTo(ss2.modified));
        break;
      case ServerSortMode.name:
        ssList.sort((ss1, ss2) => ss1.name.compareTo(ss2.name));
        break;
      case ServerSortMode.encrypt:
        ssList.sort((ss1, ss2) => ss1.encrypt.compareTo(ss2.encrypt));
        break;
    }

    var even = false;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: ssList.map<Widget>((shadowsocks) {
          even = !even;
          return _buildItem(even, shadowsocks);
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _settings.status.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _settings.status.removeListener(_onStatusChanged);
    super.dispose();
  }
}
