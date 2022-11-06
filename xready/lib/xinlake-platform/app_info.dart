import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:xinlake_platform/xinlake_platform.dart';

class AppInfoDemo extends StatefulWidget {
  const AppInfoDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return kIsWeb || Platform.isAndroid || Platform.isWindows;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<AppInfoDemo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfoDemo> {
  // parameters
  bool _versionFlutterStyle = false;
  XinAndroidAppDir _androidDir = XinAndroidAppDir.internalCache;

  // results
  String? _appVersion;
  String? _buildNumber;
  DateTime? _appUpdated;
  String? _appDir;

  bool _enableAndroidDir = false;
  final _xinPlatform = XinPlatform();

  void _getAppVersion() async {
    final verInfo = await _xinPlatform.getAppVersion(flutterStyle: _versionFlutterStyle);
    setState(() {
      _appVersion = verInfo?.version;
      _buildNumber = verInfo?.buildNumber.toString();
      _appUpdated = verInfo?.lastUpdatedTime;
    });
  }

  void _getAppDir() async {
    final appDir = await _xinPlatform.getAppDir(
      androidAppDir: _enableAndroidDir ? _androidDir : null,
    );

    setState(() => _appDir = appDir);
  }

  Widget _buildAppVersion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Windows app version in Flutter style"),
                Switch(
                  value: _versionFlutterStyle,
                  onChanged: (value) => setState(() => _versionFlutterStyle = value),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _getAppVersion,
              child: const Text("getAppVersion"),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'version: ',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: _appVersion ?? "NULL",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'build: ',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: _buildNumber ?? "NULL",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'updated: ',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: _appUpdated?.toString() ?? "NULL",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDir() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppDirParameter(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getAppDir,
              child: const Text("getAppDir"),
            ),
            const SizedBox(height: 10),
            Text(
              _appDir ?? "NULL",
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDirParameter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Android app dir"),
            Switch(
              value: _enableAndroidDir,
              onChanged: (value) => setState(() => _enableAndroidDir = value),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButton<XinAndroidAppDir>(
          underline: Container(
            height: 1,
            color: Theme.of(context).colorScheme.background,
          ),
          value: _androidDir,
          onChanged: _enableAndroidDir
              ? (newValue) {
                  setState(() => _androidDir = newValue!);
                }
              : null,
          items: XinAndroidAppDir.values.map<DropdownMenuItem<XinAndroidAppDir>>((item) {
            return DropdownMenuItem<XinAndroidAppDir>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // app version
          _buildAppVersion(),
          const SizedBox(height: 10),
          // app dir
          _buildAppDir(),
        ],
      ),
    );
  }
}
