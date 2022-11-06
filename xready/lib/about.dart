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
  static const title = "About";

  @override
  State<AboutPage> createState() => _AboutState();
}

class _AboutState extends State<AboutPage> {
  final _xinPlatform = XinPlatform();

  Widget _buildAbout() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const iconImage = Image(
      image: AssetImage('images/icon.png'),
      width: 70,
      height: 70,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // logo
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconImage,
            const SizedBox(width: 20),
            Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Xinlake",
                        style: TextStyle(
                          fontSize: 24,
                          color: primaryColor,
                        ),
                      ),
                      const TextSpan(
                        text: " Packages",
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
                  future: _xinPlatform.getAppVersion(),
                  builder: (context, snapshot) {
                    final demoVersion = (snapshot.hasData && snapshot.data != null)
                        ? "Demo v${snapshot.data!.version}"
                        : "Demo";
                    return Text(
                      demoVersion,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    );
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
            final verInfo = await _xinPlatform.getAppVersion();
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
            await launchUrl(
              Uri.parse(gPrivacyPolicy),
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: "_blank",
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildAbout(),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "xinlake_platform, xinlake_text, xinlake_responsive are only available on GitHub",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
