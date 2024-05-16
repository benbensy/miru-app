import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    this.extensionRuntime,
    required this.url,
  });

  final ExtensionService? extensionRuntime;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String url = "";
  late Uri loadUrl = Uri.parse(url);
  final cookieManager = WebviewCookieManager();

  _setCookie() async {
    if (loadUrl.host != Uri.parse(url).host) {
      return;
    }
    final cookies = await cookieManager.getCookies(loadUrl.toString());
    final cookieString =
        cookies.map((e) => '${e.name}=${e.value}').toList().join(';');
    debugPrint('$url $cookieString');
    widget.extensionRuntime?.setCookie(
      cookieString,
    );
  }

  @override
  void initState() {
    if (widget.extensionRuntime == null) {
      url = widget.url;
    } else {
      url = widget.extensionRuntime!.extension.webSite + widget.url;
    }
    super.initState();
  }

  @override
  void dispose() {
    _setCookie();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(url.toString()),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(url),
        ),
        initialSettings: InAppWebViewSettings(
          userAgent: MiruStorage.getUASetting(),
        ),
        onLoadStart: (controller, url) {
          setState(() {
            loadUrl = url!;
          });
        },
      ),
    );
  }
}
