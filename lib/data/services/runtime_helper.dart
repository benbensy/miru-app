import 'package:get/get.dart';
import 'package:miru_app/data/services/js_runtime.dart';
import 'dart:io';

import 'package:flutter_js/flutter_js.dart';
import 'package:miru_app/data/services/runtime_handle.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/utils/extension.dart';

class RuntimeHelper {
  factory RuntimeHelper() => _getInstance();

  static RuntimeHelper get instance => _getInstance();
  static RuntimeHelper? _instance;

  RuntimeHelper._internal();

  static RuntimeHelper _getInstance() {
    _instance ??= RuntimeHelper._internal();
    return _instance!;
  }

  JavascriptRuntime runtime = JsRuntime.runtime!;
  Extension? extension;
  String currentRequestUrl = '';
  String className = '';

  Future<JavascriptRuntime> getRuntime(Extension ext) async {
    className = handleClassName(ext);
    if (extension == null || extension!.package != ext.package) {
      extension = ext;
      RuntimeHandle(runtime, extension!, className).attachHandleBridge();
      await _runExtension();
    }
    return runtime;
  }

  String handleClassName(Extension ext) {
    var className = ext.package.replaceAll('.', '');
    if (!className.isAlphabetOnly) {
      className = "${className.replaceAll(RegExp(r'[^a-zA-z]'), '')}Renamed";
    }
    return className;
  }

  Future<void> _runExtension() async {
    final file =
        File('${ExtensionUtils.extensionsDir}/${extension!.package}.js');
    final content = file.readAsStringSync();
    await _initRunExtension(content);
  }

  _initRunExtension(String extScript) async {
    final ext = extScript.replaceAll(RegExp(r'export default class.*'), '''
    class $className extends Extension { 
      constructor(extension) {
          super(extension);
      }
    ''');
    var extJson = '''{
      "className": "$className",
      "package": "${extension!.package}",
      "name": "${extension!.name}",
      "webSite": "${extension!.webSite}"
    }''';
    final extJs = '''
      $ext
      if(typeof ${className}Instance !== 'undefined'){
        delete ${className}Instance;
      }
      var ${className}Instance = new $className($extJson);
      ${className}Instance.load().then(()=>{
        if(${Platform.isLinux || Platform.isIOS}){
           DartBridge.sendMessage("cleanSettings$className",JSON.stringify([extension.settingKeys]));
        }
        sendMessage("cleanSettings", JSON.stringify([extension.settingKeys]));
      });
    ''';
    runtime.evaluate(extJs);
  }
}
