import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/request.dart';

cleanCookie(Extension extension) async {
  await MiruRequest.cleanCookie(extension.webSite);
}

/// 添加 cookie
/// key=value; key=value
setCookie(Extension extension, String cookies) async {
  await MiruRequest.setCookie(cookies, extension.webSite);
}

// 列出所有的 cookie
Future<String> listCookie(Extension extension) async {
  return await MiruRequest.getCookie(extension.webSite);
}
