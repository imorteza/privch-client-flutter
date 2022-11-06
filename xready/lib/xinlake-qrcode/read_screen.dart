import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

class ReadScreenDemo extends StatefulWidget {
  const ReadScreenDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return Platform.isWindows;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<ReadScreenDemo> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreenDemo> {
  // result
  var _codeList = <String>[];

  var _reading = false;

  Future<void> _readScreen() async {
    setState(() => _reading = true);
    final codeList = await XinQrcode.readScreen();

    setState(() {
      _codeList = codeList ?? [];
      _reading = false;
    });
  }

  Widget _buildResults() {
    if (_reading) {
      return const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_codeList.isEmpty) {
      return const Center(
        child: Text(
          "READY",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 32,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: List<Widget>.generate(
          _codeList.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text("${index + 1}"),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(_codeList[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text("Not supported"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            child: const Text("readScreen"),
            onPressed: () async => _readScreen(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }
}
