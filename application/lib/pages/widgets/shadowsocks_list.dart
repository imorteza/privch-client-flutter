/*
  Xinlake Liu
  2022-03
 */

import 'package:flutter/material.dart';

import 'package:privch/models/server_manager.dart';
import 'package:privch/models/server_state.dart';
import 'package:privch/models/setting_manager.dart';
import 'package:privch/models/shadowsocks.dart';
import 'package:privch/pages/shadowsocks_detail.dart';
import 'package:privch/pages/widgets/shadowsocks_widget.dart';

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
  final _setting = SettingManager.instance;

  void _onItemDetail(Shadowsocks shadowsocks) async {
    // navigate to shadowsocks details
    final checked = await Navigator.pushNamed(
      context,
      ShadowsocksDetailPage.route,
      arguments: shadowsocks,
    ) as bool?;
    if (checked != null && checked) {
      shadowsocks.save();
    }
  }

  void _onItemSelected(Shadowsocks shadowsocks) {
    _setting.serverState.currentServer = shadowsocks;
  }

  Future<void> _onItemRemove(Shadowsocks shadowsocks) async {
    // remove the server
    if (await _servers.delete(shadowsocks)) {
      // cancel remove
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

  void _onServerStateChange() {
    setState(() {});
  }

  /// item left background on swipe
  Widget _buildItemBgLeft() {
    final ThemeData themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.onPrimary,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: themeData.backgroundColor,
          ),
          const SizedBox(width: 8),
          Text(
            "Delete",
            style: TextStyle(color: themeData.backgroundColor),
          ),
        ],
      ),
    );
  }

  /// item right background on swipe
  Widget _buildItemBgRight() {
    final ThemeData themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.onPrimary,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Edit",
            style: TextStyle(color: themeData.backgroundColor),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_back,
            color: themeData.backgroundColor,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Shadowsocks shadowsocks) {
    return Dismissible(
      key: Key("${shadowsocks.hashCode}"),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.6,
        DismissDirection.endToStart: 0.2,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _onItemDetail(shadowsocks);
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          // delete server
          return true;
        }
        return false;
      },
      onDismissed: (direction) {
        _onItemRemove(shadowsocks);
      },
      child: ShadowsocksWidget(
        onTap: () => _onItemSelected(shadowsocks),
        shadowsocks: shadowsocks,
      ),
      background: _buildItemBgLeft(),
      secondaryBackground: _buildItemBgRight(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_setting.serverState.serverCount < 1) {
      return widget.empty;
    }

    final ssList = _servers.servers.toList();
    switch (_setting.serverState.sortMode) {
      case ServerSortMode.modified:
        ssList.sort((ss1, ss2) => -ss1.modified.compareTo(ss2.modified));
        break;
      case ServerSortMode.address:
        ssList.sort((ss1, ss2) => ss1.address.compareTo(ss2.address));
        break;
      case ServerSortMode.name:
        ssList.sort((ss1, ss2) => ss1.name.compareTo(ss2.name));
        break;
    }

    return ListView(
      scrollDirection: Axis.vertical,
      children: ssList.map<Widget>((shadowsocks) {
        return _buildItem(shadowsocks);
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _setting.serverState.addListener(_onServerStateChange);
  }

  @override
  void dispose() {
    _setting.serverState.removeListener(_onServerStateChange);
    super.dispose();
  }
}
