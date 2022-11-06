import 'package:flutter/material.dart';

import 'global.dart';
import 'home.dart';

void main() {
  runApp(const ReadyApp());
}

class ReadyApp extends StatelessWidget {
  const ReadyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: gNotifyDarkMode,
      builder: (BuildContext context, bool darkMode, Widget? child) {
        return MaterialApp(
          title: 'Xinlake Packages',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            errorColor: Colors.orange,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            errorColor: Colors.deepOrange,
          ),
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}
