import 'package:flutter/material.dart';
import 'package:xinlake_text/formatter.dart';

class FormatterDemo extends StatefulWidget {
  const FormatterDemo({Key? key}) : super(key: key);

  @override
  State<FormatterDemo> createState() => _FormatterState();
}

class _FormatterState extends State<FormatterDemo> {
  static const InputDecoration _decoration = InputDecoration(
    contentPadding: EdgeInsets.only(top: 8, bottom: 4),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        maxLines: null,
        scrollController: ScrollController(),
        decoration: _decoration.copyWith(
          label: const Text("Disallow line break when input"),
        ),
        inputFormatters: [
          RemoveBreakFormatter(
            onLineWrap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("No line break"),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
