import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

class FromCameraDemo extends StatefulWidget {
  const FromCameraDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return Platform.isAndroid;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<FromCameraDemo> createState() => _FromCameraState();
}

class _FromCameraState extends State<FromCameraDemo> {
  String? _prefix;
  bool _playBeep = true;
  bool _frontFace = false;

  // result
  String? _qrcode;

  void _fromCamera() async {
    final qrcode = await XinQrcode.fromCamera(
      accentColor: Theme.of(context).colorScheme.secondary.value,
      prefix: _prefix,
      playBeep: _playBeep,
      frontFace: _frontFace,
    );
    setState(() => _qrcode = qrcode);
  }

  Widget _buildCamera() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                label: Text("Prefix"),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
                ),
              ),
              onChanged: (value) {
                _prefix = value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Play beep"),
                Switch(
                  value: _playBeep,
                  onChanged: (value) => setState(() => _playBeep = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Use front camera"),
                Switch(
                  value: _frontFace,
                  onChanged: (value) => setState(() => _frontFace = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fromCamera,
              child: const Text("Scan QRCode"),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            SelectableText(
              _qrcode ?? "NULL",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text("Not supported"),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: _buildCamera(),
    );
  }
}
