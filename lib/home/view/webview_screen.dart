import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String htmlFilePath;

  const WebViewScreen({super.key, required this.htmlFilePath});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with WidgetsBindingObserver {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFile(widget.htmlFilePath);
  }

  @override
  void dispose() {
    _pauseMedia();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pauseMedia();
    }
  }

  void _pauseMedia() {
    try {
      _controller.runJavaScript(
          "document.querySelectorAll('video, audio').forEach(media => media.pause());"
      );
    } catch (e) {
      print("Error executing JavaScript pause sequence: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _pauseMedia();
            context.pop();
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}