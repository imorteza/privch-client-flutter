import 'package:flutter/material.dart';

import 'package:privch/models/shadowsocks.dart';

class EncryptListPage extends StatefulWidget {
  const EncryptListPage({
    required this.encrypt,
    Key? key,
  }) : super(key: key);

  final String encrypt;

  @override
  _EncryptListState createState() => _EncryptListState();
}

class _EncryptListState extends State<EncryptListPage> {
  late String _encrypt;

  Widget _buildList() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ssEncryptMethods.map((item) {
        // item pressed
        void pressed() => setState(() => _encrypt = item);
        // item child
        final child = Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            item.toUpperCase(),
            textAlign: TextAlign.center,
          ),
        );
        // item widget
        return (_encrypt == item)
            ? ElevatedButton(onPressed: pressed, child: child)
            : OutlinedButton(onPressed: pressed, child: child);
      }).toList(),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Encrypt Method"),
        const SizedBox(height: 5),
        Text(
          _encrypt.toUpperCase(),
          textScaleFactor: 0.6,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                (_encrypt != widget.encrypt) ? () => Navigator.of(context).pop(_encrypt) : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: _buildList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _encrypt = widget.encrypt;
  }
}
