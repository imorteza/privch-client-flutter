/*
  Xinlake Liu
  2022-04

  - "setState(() {});" is not a good practice
 */

import 'package:flutter/material.dart';

import '../../models/setting_manager.dart';
import '../../models/shadowsocks/shadowsocks07.dart';

class ShadowsocksWidget extends StatefulWidget {
  const ShadowsocksWidget({
    required this.onTap,
    required this.shadowsocks,
    Key? key,
  }) : super(key: key);

  final void Function() onTap;
  final Shadowsocks shadowsocks;

  @override
  State<StatefulWidget> createState() => _ShadowsocksState();
}

class _ShadowsocksState extends State<ShadowsocksWidget> {
  final _setting = SettingManager.instance;

  @override
  Widget build(BuildContext context) {
    final shadowsocks = widget.shadowsocks;
    final selected = (shadowsocks.id == _setting.status.currentServer?.id);
    final themeData = Theme.of(context);

    return Container(
      color: selected ? themeData.secondaryHeaderColor : null,
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // selection indicator
            Container(
              height: 45,
              width: 8,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: selected ? themeData.colorScheme.secondary : null,
            ),
            // shadowsocks info
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(shadowsocks.name, textScaleFactor: 1.4),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shadowsocks.modified,
                            style: themeData.textTheme.caption,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // TODO: "${ss.responseTime.value}ms",
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.shadowsocks.onSaved = () => setState(() {});
  }

  @override
  void dispose() {
    widget.shadowsocks.onSaved = null;
    super.dispose();
  }
}
