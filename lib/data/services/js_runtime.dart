import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/handle_promises.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:flutter_js/javascriptcore/jscore_runtime.dart';
import 'package:flutter_js/quickjs/quickjs_runtime2.dart';

class JsRuntime {
  static bool _initialized = false;
  static JavascriptRuntime? runtime;

  static ensureInitialized() {
    if (_initialized) return;
    _initJsRuntime();
    _runJs();
    _initialized = true;
  }

  static void _initJsRuntime() async {
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
    if (Platform.isIOS) {
      runtime!.setInspectable(true);
    }
  }

  static void _runJs() async {
    final cryptoJs = await rootBundle.loadString('assets/js/CryptoJS.min.js');
    final jsEncrypt = await rootBundle.loadString('assets/js/jsencrypt.min.js');
    final md5 = await rootBundle.loadString('assets/js/md5.min.js');
    final runtimeQuickJs =
        await rootBundle.loadString('assets/js/runtime.quickJs.js');
    final runtimeCoreJs =
        await rootBundle.loadString('assets/js/runtime.coreJs.js');
    final utilJs = '''
        $cryptoJs
        $jsEncrypt
        $md5
    ''';

    runtime!.evaluate(utilJs);
    if (Platform.isLinux || Platform.isIOS) {
      runtime!.evaluate(runtimeCoreJs);
    } else {
      runtime!.evaluate(runtimeQuickJs);
    }
  }
}
