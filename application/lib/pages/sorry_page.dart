/*
  Xinlake Liu
  2022-05-22
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
  Future<void> _launchMail() async {
    try {
      await launchUrl(
        Uri.parse("mailto:$gXinlakeMail"),
        mode: LaunchMode.platformDefault,
      );
    } catch (error) {
      final size = MediaQuery.of(context).size;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: size.height * 0.1,
            left: size.width * 0.1,
            right: size.width * 0.1,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Unable to perform email action"),
            ],
          ),
        ),
      );
    }
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
              onPressed: _launchMail,
              child: const Text(gXinlakeMail),
            ),
          ],
        ),
      ),
    );
  }
}
