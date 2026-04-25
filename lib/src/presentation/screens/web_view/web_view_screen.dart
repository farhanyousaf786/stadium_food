import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({
    super.key,
    required this.url,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  Future<void> _applyViewportAndSafeAreaFixes() async {
    try {
      await _webViewController.runJavaScript('''
        (function () {
          var viewport = document.querySelector('meta[name="viewport"]');
          if (!viewport) {
            viewport = document.createElement('meta');
            viewport.name = 'viewport';
            document.head.appendChild(viewport);
          }
          if (viewport && (!viewport.content || viewport.content.indexOf('viewport-fit=cover') === -1)) {
            var content = viewport.content || 'width=device-width, initial-scale=1.0';
            if (content.trim().length > 0 && content.trim().slice(-1) !== ',') {
              content = content + ',';
            }
            viewport.content = content + ' viewport-fit=cover';
          }

          var style = document.getElementById('flutter-webview-safearea-fix');
          if (!style) {
            style = document.createElement('style');
            style.id = 'flutter-webview-safearea-fix';
            style.innerHTML = `
              html, body { height: 100% !important; padding: 0 !important; margin: 0 !important; overflow-x: hidden !important; }
              body { padding-bottom: 0 !important; margin-bottom: 0 !important; }
              * { box-sizing: border-box; }
              footer, nav, [id*="bottom" i], [class*="bottom" i] { padding-bottom: 0 !important; margin-bottom: 0 !important; }
              [style*="safe-area-inset-bottom" i] { padding-bottom: 0 !important; margin-bottom: 0 !important; }
            `;
            document.head.appendChild(style);
          }
        })();
      ''');
    } catch (_) {
      // Ignore JS injection errors (some pages restrict modifications)
    }
  }

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _applyViewportAndSafeAreaFixes();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: SafeArea(
              bottom: false,
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
