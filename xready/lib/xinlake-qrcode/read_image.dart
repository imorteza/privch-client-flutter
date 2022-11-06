import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xinlake_platform/xinlake_platform.dart';
import 'package:xinlake_qrcode/xinlake_qrcode.dart';

class ReadImageDemo extends StatefulWidget {
  const ReadImageDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return Platform.isAndroid || Platform.isWindows;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<ReadImageDemo> createState() => _ReadImageState();
}

class _ReadImageState extends State<ReadImageDemo> {
  // result
  var _codeList = <String>[];

  var _reading = false;
  final _xinPlatform = XinPlatform();

  void _pickImages() async {
    final images = await _xinPlatform.pickFile(
      multiSelection: true,
      mimeTypes: "image/*",
      cacheDir: XinAndroidAppDir.externalFiles,
      typesDescription: "Image files",
    );

    // valid selection
    if (images == null || images.isEmpty) {
      return;
    }

    setState(() => _reading = true);
    final codeList = await XinQrcode.readImage(images.map<String>((image) => image.path!).toList());

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
            padding: const EdgeInsets.symmetric(vertical: 8),
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _reading ? null : _pickImages,
            child: const Text("Pick and read images"),
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
