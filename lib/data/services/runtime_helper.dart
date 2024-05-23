import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:miru_app/data/services/extension_jscore_plugin.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:miru_app/utils/request.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:flutter_js/javascriptcore/jscore_runtime.dart';

class RuntimeHelper {
  factory RuntimeHelper() => _getInstance();

  static RuntimeHelper get instance => _getInstance();
  static RuntimeHelper? _instance;

  RuntimeHelper._internal();

  static RuntimeHelper _getInstance() {
    _instance ??= RuntimeHelper._internal();
    return _instance!;
  }

  JavascriptRuntime? runtime;
  JsBridge? jsBridge;
  Extension? extension;

  String currentRequestUrl = '';
  String className = '';

  Future<JavascriptRuntime> getRuntime(Extension ext) async {
    if (runtime == null && jsBridge == null && extension == null) {
      return _initJsRuntime(ext);
    } else {
      if (extension!.package == ext.package) {
        return runtime!;
      } else {
        runtime!.dispose();
        runtime = null;
        jsBridge = null;
        extension = null;
        extension = ext;
        return _initJsRuntime(ext);
      }
    }
  }

  Future<JavascriptRuntime> _initJsRuntime(Extension ext) async {
    extension = ext;
    className = extension!.package.replaceAll('.', '');
    // example: if the package name is com.example.extension the class name will be comexampleextension
    // but if  the package name is 9anime.to the class name will be animetoRenamed

    if (!className.isAlphabetOnly) {
      className = "${className.replaceAll(RegExp(r'[^a-zA-z]'), '')}Renamed";
    }
    if (Platform.isAndroid) {
      runtime = QuickJsRuntime2(stackSize: 1024 * 1024);
    } else if (Platform.isWindows) {
      runtime = QuickJsRuntime2();
    } else if (Platform.isLinux) {
      runtime = JavascriptCoreRuntime();
    } else {
      runtime = JavascriptCoreRuntime();
    }
    runtime!.enableFetch();
    runtime!.enableHandlePromises();
    final file =
        File('${ExtensionUtils.extensionsDir}/${extension!.package}.js');
    final content = file.readAsStringSync();
    _initHandleBridge(className);
    await _initRunExtension(content);
    return runtime!;
  }

  String _handleAssetsJs(String js) {
    var map = {
      "\$className": className,
      "\${extension.package}": extension!.package,
      "\${extension.name}": extension!.name,
      "\${extension.webSite}": extension!.webSite
    };
    map.forEach((key, value) {
      js = js.replaceAll(key, value);
    });
    return js;
  }

  _initRunExtension(String extScript) async {
    final cryptoJs = await rootBundle.loadString('assets/js/CryptoJS.min.js');
    final jsencrypt = await rootBundle.loadString('assets/js/jsencrypt.min.js');
    final md5 = await rootBundle.loadString('assets/js/md5.min.js');
    final runtimeJs =
        await rootBundle.loadString('assets/js/runtime.common.js');
    final runtimeLinuxJs =
        await rootBundle.loadString('assets/js/runtime.linux.js');
    runtime!.evaluate((Platform.isLinux || Platform.isIOS)
        ? '''
        $cryptoJs
        $jsencrypt
        $md5
        ${_handleAssetsJs(runtimeLinuxJs)}
        '''
        : '''
          // 重写 console.log
          var window = (global = globalThis);
          $cryptoJs
          $jsencrypt
          $md5
          ${_handleAssetsJs(runtimeJs)}
          ''');

    final ext = extScript.replaceAll(RegExp(r'export default class.*'),
        'class $className extends Extension {');

    runtime!.evaluate('''
      $ext
      if(typeof ${className}Instance !== 'undefined'){
        delete ${className}Instance;
      }
      var ${className}Instance = new $className();
      ${className}Instance.load().then(()=>{
        if(${Platform.isLinux || Platform.isIOS}){
           DartBridge.sendMessage("cleanSettings$className",JSON.stringify([extension.settingKeys]));
        }
        sendMessage("cleanSettings", JSON.stringify([extension.settingKeys]));
      });
    ''');
  }

  void _initHandleBridge(String className) {
    jsLog(dynamic args) {
      logger.info(args[0]);
      ExtensionUtils.addLog(
        extension!,
        ExtensionLogLevel.info,
        args[0],
      );
    }

    jsRequest(dynamic args) async {
      currentRequestUrl = args[0];
      final headers = args[1]['headers'] ?? {};
      if (headers['User-Agent'] == null) {
        headers['User-Agent'] = MiruStorage.getUASetting();
      }

      final url = args[0];
      final method = args[1]['method'] ?? 'get';
      final requestBody = args[1]['data'];

      final log = ExtensionNetworkLog(
        extension: extension!,
        url: args[0],
        method: method,
        requestHeaders: headers,
      );
      final key = UniqueKey().toString();
      ExtensionUtils.addNetworkLog(
        key,
        log,
      );

      try {
        final res = await dio.request<String>(
          url,
          data: requestBody,
          queryParameters: args[1]['queryParameters'] ?? {},
          options: Options(
            headers: headers,
            method: method,
          ),
        );
        log.requestHeaders = res.requestOptions.headers;
        log.responseBody = res.data;
        log.responseHeaders = res.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = res.statusCode;

        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        return res.data;
      } on DioException catch (e) {
        log.url = e.requestOptions.uri.toString();
        log.requestHeaders = e.requestOptions.headers;
        log.responseBody = e.response?.data;
        log.responseHeaders = e.response?.headers.map.map(
          (key, value) => MapEntry(
            key,
            value.join(';'),
          ),
        );
        log.statusCode = e.response?.statusCode;
        ExtensionUtils.addNetworkLog(
          key,
          log,
        );
        rethrow;
      }
    }

    jsRegisterSetting(dynamic args) async {
      args[0]['package'] = extension!.package;

      return DatabaseService.registerExtensionSetting(
        ExtensionSetting()
          ..package = extension!.package
          ..title = args[0]['title']
          ..key = args[0]['key']
          ..value = args[0]['value']
          ..type = ExtensionSetting.stringToType(args[0]['type'])
          ..description = args[0]['description']
          ..defaultValue = args[0]['defaultValue']
          ..options = jsonEncode(args[0]['options']),
      );
    }

    jsGetMessage(dynamic args) async {
      final setting = await DatabaseService.getExtensionSetting(
          extension!.package, args[0]);
      return setting!.value ?? setting.defaultValue;
    }

    jsCleanSettings(dynamic args) async {
      // debugPrint('cleanSettings: ${args[0]}');
      return DatabaseService.cleanExtensionSettings(
          extension!.package, List<String>.from(args[0]));
    }

    jsQuerySelector(dynamic args) {
      final content = args[0];
      final selector = args[1];
      final fun = args[2];

      final doc = parse(content).querySelector(selector);
      String result = '';
      switch (fun) {
        case 'text':
          result = doc?.text ?? '';
        case 'outerHTML':
          result = doc?.outerHtml ?? '';
        case 'innerHTML':
          result = doc?.innerHtml ?? '';
        default:
          result = doc?.outerHtml ?? '';
      }
      return result;
    }

    jsQueryXPath(args) {
      final content = args[0];
      final selector = args[1];
      final fun = args[2];

      final xpath = HtmlXPath.html(content);
      final result = xpath.queryXPath(selector);
      String returnVal = '';
      switch (fun) {
        case 'attr':
          returnVal = result.attr ?? '';
        case 'attrs':
          returnVal = jsonEncode(result.attrs);
        case 'text':
          returnVal = result.node?.text ?? '';
        case 'allHTML':
          returnVal = result.nodes
              .map((e) => (e.node as Element).outerHtml)
              .toList()
              .toString();
        case 'outerHTML':
          returnVal = (result.node?.node as Element).outerHtml;
        default:
          returnVal = result.node?.text ?? "";
      }
      return returnVal;
    }

    jsRemoveSelector(dynamic args) {
      final content = args[0];
      final selector = args[1];
      final doc = parse(content);
      doc.querySelectorAll(selector).forEach((element) {
        element.remove();
      });
      return doc.outerHtml;
    }

    jsGetAttributeText(args) {
      final content = args[0];
      final selector = args[1];
      final attr = args[2];
      final doc = parse(content).querySelector(selector);
      return doc?.attributes[attr];
    }

    jsQuerySelectorAll(dynamic args) async {
      final content = args["content"];
      final selector = args["selector"];
      final doc = parse(content).querySelectorAll(selector);
      final elements = jsonEncode(doc.map((e) {
        return e.outerHtml;
      }).toList());
      return elements;
    }

    runtime!.onMessage('getSetting', (dynamic args) => jsGetMessage(args));
    // 日志
    runtime!.onMessage('log', (args) => jsLog(args));
    // 请求
    runtime!.onMessage('request', (args) => jsRequest(args));
    // 设置
    runtime!.onMessage('registerSetting', (args) => jsRegisterSetting(args));
    // 清理扩展设置
    runtime!
        .onMessage('cleanSettings', (dynamic args) => jsCleanSettings(args));
    // xpath 选择器
    runtime!.onMessage('queryXPath', (arg) => jsQueryXPath(arg));
    runtime!.onMessage('removeSelector', (args) => jsRemoveSelector(args));
    // 获取标签属性
    runtime!.onMessage('getAttributeText', (args) => jsGetAttributeText(args));
    runtime!.onMessage(
        'querySelectorAll', (dynamic args) => jsQuerySelectorAll(args));
    // css 选择器
    runtime!.onMessage('querySelector', (arg) => jsQuerySelector(arg));
    if (Platform.isLinux || Platform.isIOS) {
      handleDartBridge(String channelName, Function fn) {
        jsBridge!.setHandler(channelName, (message) async {
          final args = jsonDecode(message);
          final result = await fn(args);
          await jsBridge!.sendMessage(channelName, result);
        });
      }

      jsBridge = JsBridge(jsRuntime: runtime!);
      handleDartBridge('cleanSettings$className', jsCleanSettings);
      handleDartBridge('request$className', jsRequest);
      handleDartBridge('log$className', jsLog);
      handleDartBridge('queryXPath$className', jsQueryXPath);
      handleDartBridge('removeSelector$className', jsRemoveSelector);
      handleDartBridge("getAttributeText$className", jsGetAttributeText);
      handleDartBridge('querySelectorAll$className', jsQuerySelectorAll);
      handleDartBridge('querySelector$className', jsQuerySelector);
      handleDartBridge('registerSetting$className', jsRegisterSetting);
      handleDartBridge('getSetting$className', jsGetMessage);
    }
  }
}
