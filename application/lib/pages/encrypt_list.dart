/*
  Xinlake Liu
  2022-04-12
 */

import 'package:flutter/material.dart';

import '../models/shadowsocks.dart';

class EncryptListPage extends StatefulWidget {
  const EncryptListPage({
    Key? key,
    required this.encrypt,
  }) : super(key: key);

  static const route = "/home/shadowsocks/encrypt";
  final String encrypt;

  @override
  State<StatefulWidget> createState() => _EncryptListState();
}

class _EncryptListState extends State<EncryptListPage> {
  late String _encrypt;

  Widget _buildList() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final dividerColor = Theme.of(context).dividerColor;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ssEncryptMethods.map((item) {
        // selected item
        if (_encrypt == item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: primaryColor,
            ),
            child: Text(
              item,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
              ),
            ),
          );
        }

        // not selected items
        return InkWell(
          onTap: () => setState(() => _encrypt = item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 16,
              ),
            ),
          ),
        );
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
          textScaleFactor: 0.7,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: _buildTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (_encrypt != widget.encrypt) ? () => Navigator.pop(context, _encrypt) : null,
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
    _encrypt = widget.encrypt.toUpperCase();
  }
}
