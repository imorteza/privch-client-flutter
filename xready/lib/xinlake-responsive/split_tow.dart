import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_responsive/split_two.dart';

class SplitTwoDemo extends StatefulWidget {
  const SplitTwoDemo({Key? key}) : super(key: key);

  @override
  State<SplitTwoDemo> createState() => _SplitTwoState();
}

class _SplitTwoState extends State<SplitTwoDemo> {
  late bool _mobile;
  late bool _portrait;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Landscape / Portrait"),
            Switch(
              value: _portrait,
              onChanged: (value) => setState(() => _portrait = value),
            )
          ],
        ),
        const Divider(),
        Expanded(
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 100),
            child: SplitTwo(
              childA: const Center(child: Text("A")),
              childB: const Center(child: Text("B")),
              isPortrait: _portrait,
              dividerSize: _mobile ? 20 : 5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      _mobile = Platform.isAndroid || Platform.isIOS;
    } catch (error) {
      // dart.io don't support web
      _mobile = false;
    }

    _portrait = _mobile;
  }
}
