import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xinlake_platform/xinlake_platform.dart';

class PickFileDemo extends StatefulWidget {
  const PickFileDemo({Key? key}) : super(key: key);

  static bool get supported {
    try {
      return Platform.isAndroid || Platform.isWindows;
    } catch (exception) {
      return false;
    }
  }

  @override
  State<PickFileDemo> createState() => _PickFileState();
}

class _PickFileState extends State<PickFileDemo> {
  // parameters
  bool _multiSelection = false;
  String _types = "image/*";
  XinAndroidAppDir _cacheDir = XinAndroidAppDir.internalCache;
  bool _cacheOverwrite = false;
  String? _openPath;
  String? _defaultPath;
  String? _typesDescription;

  // result
  List<XinFile>? _pathList;

  bool _enableCache = false;
  final _xinPlatform = XinPlatform();

  late Widget Function() _buildPlatformParameters;

  void _pickFile() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
              SizedBox(width: 20),
              Text("Preparing ..."),
            ],
          ),
        );
      },
    );

    final pathList = await _xinPlatform.pickFile(
      multiSelection: _multiSelection,
      mimeTypes: _types,
      cacheDir: _enableCache ? _cacheDir : null,
      cacheOverwrite: _cacheOverwrite,
      openPath: _openPath,
      defaultPath: _defaultPath,
      typesDescription: _typesDescription,
    );

    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _pathList = pathList);
  }

  Widget _buildResults() {
    final style = Theme.of(context).textTheme.caption;
    // empty view
    if (_pathList == null) {
      return Center(
        child: Text(
          "READY",
          textScaleFactor: 2,
          style: style,
        ),
      );
    } else if (_pathList!.isEmpty) {
      return Center(
        child: Text(
          "NO FILE",
          textScaleFactor: 2,
          style: style,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_pathList!.length} ${_pathList!.length > 1 ? "files" : "file"} selected",
          style: style,
        ),
        const SizedBox(height: 5),
        Table(
          border: TableBorder.all(width: 1, color: Colors.grey),
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: FlexColumnWidth(),
          },
          children: _pathList!.map<TableRow>((xinFile) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(xinFile.name),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${xinFile.length}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(xinFile.modifiedDate?.toString() ?? 'No data'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(xinFile.data != null ? 'Loaded' : 'No data'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    xinFile.path ?? 'No data',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // android
  Widget _buildAndroidParameters() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Mime type"),
          initialValue: _types,
          onChanged: (value) => _types = value,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Cache to"),
            Switch(
              value: _enableCache,
              onChanged: (value) => setState(() => _enableCache = value),
            ),
          ],
        ),
        DropdownButton<XinAndroidAppDir>(
          underline: Container(
            height: 1,
            color: Theme.of(context).colorScheme.background,
          ),
          value: _cacheDir,
          isDense: true,
          onChanged: _enableCache
              ? (newValue) {
                  setState(() => _cacheDir = newValue!);
                }
              : null,
          items: XinAndroidAppDir.values.map<DropdownMenuItem<XinAndroidAppDir>>((item) {
            return DropdownMenuItem<XinAndroidAppDir>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Overwrite cache"),
            Switch(
              value: _cacheOverwrite,
              onChanged: (value) => setState(() => _cacheOverwrite = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWindowsParameters() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Open path"),
                initialValue: _openPath,
                onChanged: (value) => _openPath = value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Default path"),
                initialValue: _defaultPath,
                onChanged: (value) => _defaultPath = value,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Type description"),
                initialValue: _typesDescription,
                onChanged: (value) => _typesDescription = value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "MIME Type"),
                initialValue: _types,
                onChanged: (value) => _types = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebParameters() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "MIME Type"),
                initialValue: _types,
                onChanged: (value) => _types = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // all platform
  Widget _buildParameter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Enable multi selection"),
            Switch(
              value: _multiSelection,
              onChanged: (value) => setState(() => _multiSelection = value),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildParameter(),
          _buildPlatformParameters(),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text("pickFile"),
          ),
          const SizedBox(height: 10),
          _buildResults(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _buildPlatformParameters = _buildWebParameters;
    } else if (Platform.isAndroid) {
      _buildPlatformParameters = _buildAndroidParameters;
    } else if (Platform.isWindows) {
      _buildPlatformParameters = _buildWindowsParameters;
    } else {
      _buildPlatformParameters = () => const SizedBox(height: 10);
    }
  }
}
