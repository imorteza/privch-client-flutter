import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SorryPage extends StatefulWidget {
  const SorryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SorryState();
}

class _SorryState extends State<SorryPage> {
  static const _xinlakeDev = "https://xinlake.dev";
  final _loading = ValueNotifier(false);

  Future<void> _launchUrl(String url) async {
    // TODO: necessary?
    _loading.value = true;
    await launch(
      url,
      forceWebView: true,
      enableJavaScript: true,
    );
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (context, loading, child) {
          if (loading) {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Unable to initialize, Sorry!",
                  textScaleFactor: 1.2,
                ),
                TextButton(
                  child: const Text(_xinlakeDev),
                  onPressed: () => _launchUrl(_xinlakeDev),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
