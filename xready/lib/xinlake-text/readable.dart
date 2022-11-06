import 'package:flutter/material.dart';
import 'package:xinlake_text/readable.dart';

class ReadableDemo extends StatefulWidget {
  const ReadableDemo({Key? key}) : super(key: key);

  @override
  State<ReadableDemo> createState() => _ReadableState();
}

class _ReadableState extends State<ReadableDemo> {
  var _decimals = 3;
  int? _input;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Text(
              (_input != null) ? Readable.formatSize(_input!, decimals: _decimals) : "NULL",
              style: const TextStyle(
                fontSize: 32,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Decimals:"),
              Row(
                children: [
                  Radio<int>(
                    value: 2,
                    groupValue: _decimals,
                    onChanged: (value) => setState(() => _decimals = value!),
                  ),
                  const Text("2"),
                ],
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 3,
                    groupValue: _decimals,
                    onChanged: (value) => setState(() => _decimals = value!),
                  ),
                  const Text("3"),
                ],
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 4,
                    groupValue: _decimals,
                    onChanged: (value) => setState(() => _decimals = value!),
                  ),
                  const Text("4"),
                ],
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Text("Readable size"),
              contentPadding: EdgeInsets.only(top: 8, bottom: 4),
              suffixStyle: TextStyle(fontStyle: FontStyle.italic),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => _input = int.tryParse(value)),
          ),
        ],
      ),
    );
  }
}
