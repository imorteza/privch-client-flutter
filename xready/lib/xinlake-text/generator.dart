import 'package:flutter/material.dart';
import 'package:xinlake_text/generator.dart';

class GeneratorDemo extends StatefulWidget {
  const GeneratorDemo({Key? key}) : super(key: key);

  @override
  State<GeneratorDemo> createState() => _GeneratorDemo();
}

class _GeneratorDemo extends State<GeneratorDemo> {
  String? _password;
  var _passwordLength = 6;

  String? _ip;

  Widget _buildRandomPassword() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: SelectableText(
                _password ?? "NULL",
                style: const TextStyle(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Divider(),
            Row(
              children: [
                const Text("Length"),
                Expanded(
                  child: Slider(
                    min: 4,
                    max: 16,
                    value: _passwordLength.toDouble(),
                    onChanged: (value) {
                      setState(() => _passwordLength = value.toInt());
                    },
                  ),
                ),
                Text("$_passwordLength"),
              ],
            ),
            ElevatedButton(
              child: const Text("randomPassword"),
              onPressed: () => setState(() {
                _password = Generator.randomPassword(
                  passwordLength: _passwordLength,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomIp() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: SelectableText(
                _ip ?? "NULL",
                style: const TextStyle(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Divider(),
            ElevatedButton(
              child: const Text("randomIp"),
              onPressed: () {
                setState(() => _ip = Generator.randomIp());
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
      child: MediaQuery.of(context).size.aspectRatio > 1.2
          ? Row(
              children: [
                Expanded(child: _buildRandomPassword()),
                const SizedBox(width: 20),
                Expanded(child: _buildRandomIp()),
              ],
            )
          : Column(
              children: [
                _buildRandomPassword(),
                const SizedBox(height: 20),
                _buildRandomIp(),
              ],
            ),
    );
  }
}
