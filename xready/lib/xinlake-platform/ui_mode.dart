import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_platform/xinlake_platform.dart';

class UiModeDemo extends StatefulWidget {
  const UiModeDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return Platform.isAndroid;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<UiModeDemo> createState() => _UiModeState();
}

class _UiModeState extends State<UiModeDemo> {
  var _uiMode = XinUiMode.light;
  var _animateMs = 100.0;

  final _xinPlatform = XinPlatform();

  Widget _buildUiMode() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("System"),
                    Radio<XinUiMode>(
                      value: XinUiMode.system,
                      groupValue: _uiMode,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _uiMode = value);
                        }
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text("Light"),
                    Radio<XinUiMode>(
                      value: XinUiMode.light,
                      groupValue: _uiMode,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _uiMode = value);
                        }
                      },
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text("Dark"),
                    Radio<XinUiMode>(
                      value: XinUiMode.dark,
                      groupValue: _uiMode,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _uiMode = value);
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
            const Divider(height: 10),
            Row(
              children: [
                const Text("Animate"),
                Expanded(
                  child: Slider(
                    min: 100,
                    max: 300,
                    value: _animateMs,
                    onChanged: (value) {
                      setState(() => _animateMs = value);
                    },
                  ),
                ),
                Text("${_animateMs.toInt()} ms"),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("setUiMode"),
              onPressed: () async {
                await _xinPlatform.setUiMode(_uiMode, animateMs: _animateMs.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        _buildUiMode(),
      ]),
    );
  }
}
