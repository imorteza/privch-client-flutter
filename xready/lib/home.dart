import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_interface/window_interface.dart';

import 'about.dart';
import 'global.dart';
import 'model/demo.dart';
import 'window-interface/window.dart';
import 'xinlake-platform/app_info.dart';
import 'xinlake-platform/pick_file.dart';
import 'xinlake-platform/ui_mode.dart';
import 'xinlake-qrcode/from_camera.dart';
import 'xinlake-qrcode/read_image.dart';
import 'xinlake-qrcode/read_screen.dart';
import 'xinlake-responsive/split_tow.dart';
import 'xinlake-text/formatter.dart';
import 'xinlake-text/generator.dart';
import 'xinlake-text/readable.dart';
import 'xinlake-text/validator.dart';

final _demoList = <String, List<DemoItem>>{
  "Responsive": [
    DemoItem("SplitTwo", () => const SplitTwoDemo(), true),
  ],
  "Text": [
    DemoItem("Readable", () => const ReadableDemo(), true),
    DemoItem("Formatter", () => const FormatterDemo(), true),
    DemoItem("Validator", () => const ValidatorDemo(), true),
    DemoItem("Generator", () => const GeneratorDemo(), true),
  ],
  "QRCode": [
    DemoItem("Read Image", () => const ReadImageDemo(), ReadImageDemo.supported),
    DemoItem("From Camera", () => const FromCameraDemo(), FromCameraDemo.supported),
    DemoItem("Read Screen", () => const ReadScreenDemo(), ReadScreenDemo.supported),
  ],
  "Platform": [
    DemoItem("UI Mode", () => const UiModeDemo(), UiModeDemo.supported),
    DemoItem("Pick File", () => const PickFileDemo(), PickFileDemo.supported),
    DemoItem("App Info", () => const AppInfoDemo(), AppInfoDemo.supported),
  ],
  "Window Interface": [
    DemoItem("Window Control", () => const WindowInterfaceDemo(), WindowInterfaceDemo.supported),
  ],
};

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  var _demoItem = _demoList.entries.first.value.first;

  Widget _buildHeader() {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        // update appbar title
        setState(() {
          _demoItem = DemoItem("About", () => const AboutPage(), true);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 50, bottom: 8),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Image(
                image: AssetImage('images/icon.png'),
                width: 50,
                height: 50,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "Xinlake ",
                  style: const TextStyle(fontSize: 22),
                  children: [
                    TextSpan(
                      text: "Packages",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const TextSpan(
                      text: "\nDemo",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemos() {
    return Column(
      children: _demoList.entries.map((demo) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // package title
            Text(
              demo.key.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            // package demos
            ...demo.value.map((item) {
              return InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: item.supported ? Theme.of(context).colorScheme.secondary : Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (item.supported) {
                    setState(() => _demoItem = item);
                  } else {
                    String os;
                    try {
                      os = Platform.operatingSystem.toUpperCase();
                    } catch (exception) {
                      os = "Web";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: item.name,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " is NOT supported on ",
                                    ),
                                    TextSpan(
                                      text: os,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }).toList(),
            const Divider(height: 20),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_demoItem.name),
        actions: [
          const Center(
            child: Text("Dark Mode"),
          ),
          Switch(
            value: gNotifyDarkMode.value,
            onChanged: (newValue) {
              gNotifyDarkMode.value = newValue;
            },
          ),
        ],
      ),
      body: _demoItem.builder(),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                controller: _scrollController,
                child: _buildDemos(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      if (Platform.isWindows) {
        WindowInterface.setWindowMinSize(700, 500);
      }
    } catch (exception) {
      // ignore
    }

    Future.delayed(
      const Duration(milliseconds: 500),
      () => _scaffoldKey.currentState?.openDrawer(),
    );
  }
}
