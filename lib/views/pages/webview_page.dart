import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app/data/services/cookie_utils.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    this.extension,
    required this.url,
  });

  final Extension? extension;
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
    setCookie(widget.extension!,cookieString);
  }

  @override
  void initState() {
    if (widget.extension == null) {
      url = widget.url;
    } else {
      var webSite = widget.extension!.webSite;
      if (webSite.endsWith("/")) {
        url = widget.extension!.webSite + widget.url;
      } else {
        url = "${widget.extension!.webSite}/${widget.url}";
      }
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
