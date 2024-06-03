import 'dart:convert';
import 'dart:io';

import 'package:flutter_js/extensions/handle_promises.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:miru_app/data/services/runtime_helper.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/miru_storage.dart';

import 'cookie_utils.dart';
import 'extension_interface.dart';

class ExtensionInterfaceWrapper extends ExtensionInterface {
  ExtensionInterfaceWrapper(this.runtime, this.extension, this.className);

  JavascriptRuntime runtime;
  Extension extension;
  String className;

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

  Future<Map<String, String>> get _defaultHeaders async {
    return {
      "Referer": RuntimeHelper.instance.currentRequestUrl,
      "User-Agent": MiruStorage.getUASetting(),
      "Cookie": await listCookie(extension),
    };
  }

  @override
  Future<String> checkUpdate(String url) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(
            'stringify(()=>${className}Instance.checkUpdate("$url"))'),
      );
      return jsResult.stringResult;
    });
  }

  @override
  Future<Map<String, ExtensionFilter>?> createFilter(
      {Map<String, List<String>>? filter}) {
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
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync(eval),
      );
      if (jsResult.isError || jsResult.stringResult == "undefined") {
        return null;
      }
      Map<String, dynamic> result = jsonDecode(jsResult.stringResult);
      return result.map(
        (key, value) => MapEntry(
          key,
          ExtensionFilter.fromJson(value),
        ),
      );
    });
  }

  @override
  Future<ExtensionDetail> detail(String url) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.detail("$url")'
            : 'stringify(()=>${className}Instance.detail("$url"))'),
      );
      final result =
          ExtensionDetail.fromJson(jsonDecode(jsResult.stringResult));
      result.headers ??= await _defaultHeaders;
      return result;
    });
  }

  @override
  Future<List<ExtensionListItem>> latest(int page) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync((Platform.isLinux || Platform.isIOS)
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

  @override
  Future<List<ExtensionListItem>> search(String kw, int page,
      {Map<String, List<String>>? filter}) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync((Platform.isLinux || Platform.isIOS)
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

  @override
  Future<Object?> watch(String url) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync((Platform.isLinux || Platform.isIOS)
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

  @override
  Future<List<String>?> tags(String url) {
    return runExtension(() async {
      final jsResult = await runtime.handlePromise(
        await runtime.evaluateAsync((Platform.isLinux || Platform.isIOS)
            ? '${className}Instance.tags("$url")'
            : 'stringify(()=>${className}Instance.tags("$url"))'),
      );
      if (jsResult.isError || jsResult.stringResult == "undefined") {
        return null;
      }
      List<String> result = jsonDecode(jsResult.stringResult).map<String>((e) {
        return e;
      }).toList();
      return result;
    });
  }
}
