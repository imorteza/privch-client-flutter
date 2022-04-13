/*
  Xinlake Liu
  2022-04-12

  - Check for updates
*/

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xinlake_platform/xinlake_platform.dart';

import '../global.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);
  static const route = "/home/about";
  static const title = "About";

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<AboutPage> {
  Widget _buildAbout() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const iconImage = Image(
      image: AssetImage('.assets/icon.png'),
      width: 50,
      height: 50,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // logo
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            iconImage,
            const SizedBox(width: 20),
            Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Private",
                        style: TextStyle(
                          fontSize: 24,
                          color: primaryColor,
                        ),
                      ),
                      const TextSpan(
                        text: " Channel",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                FutureBuilder<XinVersionInfo?>(
                  future: XinPlatform.getAppVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Text(
                        "ver ${snapshot.data!.version}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      );
                    } else {
                      return const SizedBox(height: 8);
                    }
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(indent: 10, endIndent: 10, height: 20),

        // license
        InkWell(
          onTap: () async {
            final verInfo = await XinPlatform.getAppVersion();
            showLicensePage(
              context: context,
              applicationVersion: verInfo?.version,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(10),
                child: iconImage,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "VIEW LICENSE",
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // privacy
        InkWell(
          onTap: () async {
            await launch(
              gPrivacyPolicy,
              enableJavaScript: true,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "PRIVACY POLICY",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.outbound,
                  size: 20,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AboutPage.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildAbout(),
            ),
          ),
        ],
      ),
    );
  }
}
