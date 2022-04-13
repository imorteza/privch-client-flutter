/*
  Xinlake Liu
  2022-04-10
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const gXinlakeDev = "https://xinlake.dev";
const gPrivacyPolicy = "https://github.com/xinlake/privch/blob/main/PRIVACY-POLICY.md";
final gDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

// TODO: Not used
Route<T> createRoute<T>(
  Widget newPage, {
  Offset begin = const Offset(-1.0, 0.0),
  Curve curve = Curves.ease,
}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
