/*
  Xinlake Liu
  2022-02-28
 */

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SorryPage extends StatefulWidget {
  const SorryPage({Key? key}) : super(key: key);
  static const route = "/sorry";

  @override
  State<StatefulWidget> createState() => _SorryState();
}

class _SorryState extends State<SorryPage> {
  static const _xinlakeDev = "https://xinlake.dev";

  Future<void> _launchUrl(String url) async {
    await launch(
      url,
      forceWebView: true,
      enableJavaScript: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Unable to initialize, Sorry!",
              textScaleFactor: 1.2,
            ),
            TextButton(
              child: const Text(_xinlakeDev),
              onPressed: () => _launchUrl(_xinlakeDev),
            ),
          ],
        ),
      ),
    );
  }
}
