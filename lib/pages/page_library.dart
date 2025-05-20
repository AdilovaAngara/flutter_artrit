import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // Добавляем WebView
import '../widgets/app_bar_widget.dart';
import 'menu.dart';

class PageLibrary extends StatefulWidget {
  final String title;

  const PageLibrary({
    super.key,
    required this.title,
  });

  @override
  State<PageLibrary> createState() => _PageLibraryState();
}

class _PageLibraryState extends State<PageLibrary> {
  late WebViewController _webViewController;
  //bool hasError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => isLoading = progress < 100);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://aspirre-russia.ru/publikatsiya-pro/informacia-pacientam.php'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const MenuDrawer(),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}