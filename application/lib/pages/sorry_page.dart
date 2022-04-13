/*
  Xinlake Liu
  2022-02-28
 */

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global.dart';

class SorryPage extends StatefulWidget {
  const SorryPage({Key? key}) : super(key: key);
  static const route = "/sorry";
  static const title = "Sorry";

  @override
  State<StatefulWidget> createState() => _SorryState();
}

class _SorryState extends State<SorryPage> {
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
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(SorryPage.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Unable to initialize, Sorry!",
              textScaleFactor: 1.2,
            ),
            TextButton(
              child: const Text(gXinlakeDev),
              onPressed: () => _launchUrl(gXinlakeDev),
            ),
          ],
        ),
      ),
    );
  }
}
