import 'package:flutter/material.dart';

class DemoItem {
  final String name;
  final Widget Function() builder;
  final bool supported;

  DemoItem(this.name, this.builder, this.supported);
}
