import 'package:flutter/material.dart';

class AppAction {
  final IconData? icon;
  final String? description;
  final void Function() action;

  AppAction({this.icon, this.description, required this.action});
}
