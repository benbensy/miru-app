import 'dart:convert';
import 'dart:io';

import 'package:flutter_js/extensions/handle_promises.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:miru_app/data/services/runtime_helper.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

import 'cookie_utils.dart';

class ExtensionHelper {
  ExtensionHelper(this.extension);

  Extension extension;

  Future<JavascriptRuntime> get runtime async {
    return await RuntimeHelper.instance.getRuntime(extension);
  }

  String className = RuntimeHelper.instance.className;

  Future<ExtensionDetail> detail(String url) async {
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.detail("$url")'
            : 'stringify(()=>${className}Instance.detail("$url"))'),
      );
      final result =
          ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
      result.headers ??= await _defaultHeaders;
      return result;
    });
  }

  Future<Object?> watch(String url) async {
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.watch("$url")'
            : 'stringify(()=>${className}Instance.watch("$url"))'),
      );
      final data = jsonDecode(jsResult.stringResult);

      switch (extension.type) {
        case ExtensionType.bangumi:
          final result = ExtensionBangumiWatch.fromJson(data);
          result.headers ??= await _defaultHeaders;
          return result;
        case ExtensionType.manga:
          final result = ExtensionMangaWatch.fromJson(data);
          result.headers ??= await _defaultHeaders;
          return result;
        default:
          return ExtensionFikushonWatch.fromJson(data);
      }
    });
  }

  Future<String> checkUpdate(url) async {
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync(
            'stringify(()=>${className}Instance.checkUpdate("$url"))'),
      );
      return jsResult.stringResult;
    });
  }

  Future<Map<String, String>> get _defaultHeaders async {
    return {
      "Referer": RuntimeHelper.instance.currentRequestUrl,
      "User-Agent": MiruStorage.getUASetting(),
      "Cookie": await listCookie(extension),
    };
  }

  Future<List<ExtensionListItem>> latest(int page) async {
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.latest($page)'
            : 'stringify(()=>${className}Instance.latest($page))'),
      );

      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= await _defaultHeaders;
      }
      return result;
    });
  }

  Future<List<ExtensionListItem>> search(
    String kw,
    int page, {
    Map<String, List<String>>? filter,
  }) async {
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.search("$kw",$page,${filter == null ? null : jsonEncode(filter)})'
            : 'stringify(()=>${className}Instance.search("$kw",$page,${filter == null ? null : jsonEncode(filter)}))'),
      );
      List<ExtensionListItem> result =
          jsonDecode(jsResult.stringResult).map<ExtensionListItem>((e) {
        return ExtensionListItem.fromJson(e);
      }).toList();
      for (var element in result) {
        element.headers ??= await _defaultHeaders;
      }
      return result;
    });
  }

  Future<Map<String, ExtensionFilter>> createFilter({
    Map<String, List<String>>? filter,
  }) async {
    late String eval;
    if (filter == null) {
      eval = (Platform.isLinux || Platform.isIOS)
          ? '${className}Instance.createFilter()'
          : 'stringify(()=>${className}Instance.createFilter())';
    } else {
      eval = (Platform.isLinux || Platform.isIOS)
          ? '${className}Instance.createFilter(JSON.parse(\'${jsonEncode(filter)}\'))'
          : 'stringify(()=>${className}Instance.createFilter(JSON.parse(\'${jsonEncode(filter)}\')))';
    }
    return runExtension(() async {
      var r = await runtime;
      final jsResult = await r.handlePromise(
        await r.evaluateAsync(eval),
      );
      Map<String, dynamic> result = jsonDecode(jsResult.stringResult);
      return result.map(
        (key, value) => MapEntry(
          key,
          ExtensionFilter.fromJson(value),
        ),
      );
    });
  }

  Future<T> runExtension<T>(Future<T> Function() fun) async {
    try {
      return await fun();
    } catch (e) {
      ExtensionUtils.addLog(
        extension,
        ExtensionLogLevel.error,
        e.toString(),
      );
      rethrow;
    }
  }
}
