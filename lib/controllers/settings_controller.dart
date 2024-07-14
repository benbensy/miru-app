import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/extensions/handle_promises.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/services/runtime_helper.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/miru_storage.dart';

import 'application_controller.dart';

class SettingsController extends GetxController {
  final extensionLogWindowId = (-1).obs;
  final selectThemeColorIndex = 0.obs;

  final lang = {
    'languages.be'.i18n: 'be',
    'languages.en'.i18n: 'en',
    'languages.es'.i18n: 'es',
    'languages.fr'.i18n: 'fr',
    'languages.hu'.i18n: 'hu',
    'languages.hi'.i18n: 'hi',
    'languages.id'.i18n: 'id',
    'languages.ja'.i18n: 'ja',
    'languages.pl'.i18n: 'pl',
    'languages.ru'.i18n: 'ru',
    'languages.ryu'.i18n: 'ryu',
    'languages.uk'.i18n: 'uk',
    'languages.zh'.i18n: 'zh',
    'languages.zhHant'.i18n: 'zhHant',
  };

  final comic = {
    'comic-settings.standard'.i18n: 'standard',
    'comic-settings.right-to-left'.i18n: 'rightToLeft',
    'comic-settings.web-tonn'.i18n: 'webTonn',
  };

  final net = {
    'settings.proxy-type-direct'.i18n: 'DIRECT',
    'settings.proxy-type-socks5'.i18n: 'SOCKS5',
    'settings.proxy-type-socks4'.i18n: 'SOCKS4',
    'settings.proxy-type-http'.i18n: 'PROXY',
  };

  final colors = [
    0xFFD32F2F,
    0xFFD32F2F,
    0xFFC2185B,
    0xFF7B1FA2,
    0xFF512DA8,
    0xFF303F9F,
    0xFF1976D2,
    0xFF0288D1,
    0xFF0097A7,
    0xFF00796B,
    0xFF388E3C,
    0xFF689F38,
    0xFFAFB42B,
    0xFFFBC02D,
    0xFFFFA000,
    0xFFF57C00,
    0xFFE64A19,
    0xFF5D4037,
    0xFF616161,
    0xFF455A64,
  ];

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    var color = MiruStorage.getSetting(SettingKey.themeAccent);
    selectThemeColorIndex.value = colors.indexOf(color);
    super.onInit();
  }

  Map<String, dynamic> getPlayer() {
    if (Platform.isIOS) {
      return {
        "settings.external-player-builtin".i18n: "built-in",
        "VLC": "vlc",
        "Other": "other",
      };
    }
    if (Platform.isAndroid) {
      return {
        "settings.external-player-builtin".i18n: "built-in",
        "VLC": "vlc",
        "Other": "other",
      };
    }
    if (Platform.isLinux) {
      return {
        "settings.external-player-builtin".i18n: "built-in",
        "VLC": "vlc",
        "mpv": "mpv",
      };
    }
    return {
      "settings.external-player-builtin".i18n: "built-in",
      "VLC": "vlc",
      "PotPlayer": "potplayer",
    };
  }

  void changeAccent(int index) {
    if (Platform.isAndroid && index == 0) {
      MiruStorage.setSetting(SettingKey.dynamicColor, true);
    } else {
      MiruStorage.setSetting(SettingKey.dynamicColor, false);
      var offset = Platform.isAndroid ? 1 : 0;
      MiruStorage.setSetting(SettingKey.themeAccent, colors[index - offset]);
    }
    selectThemeColorIndex.value = index;
    var appController = Get.find<ApplicationController>();
    appController.changeTheme(appController.themeText);
  }

  void toggleExtensionLogWindow(bool open) async {
    if (open && extensionLogWindowId.value == -1) {
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        "name": 'debug',
      }));
      extensionLogWindowId.value = window.windowId;
      window
        ..center()
        ..setTitle("miru extension debug")
        ..show();

      // 用于检测窗口是否关闭
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        try {
          await DesktopMultiWindow.invokeMethod(
            extensionLogWindowId.value,
            "state",
          );
        } catch (e) {
          extensionLogWindowId.value = -1;
          timer.cancel();
        }
      });
      // 轮询带执行的方法并执行方法
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (extensionLogWindowId.value == -1) {
          timer.cancel();
          return;
        }
        await _handleMethods();
      });

      return;
    }
    WindowController.fromWindowId(extensionLogWindowId.value).close();
    extensionLogWindowId.value = -1;
  }

  // 返回执行结果
  _invokeMethodResult(String methodKey, dynamic result) async {
    await DesktopMultiWindow.invokeMethod(
      extensionLogWindowId.value,
      "result",
      {
        "key": methodKey,
        "result": result,
      },
    );
  }

  // 获取方法列表
  Future<List<Map<String, dynamic>>> _getMethods() async {
    final methods = await DesktopMultiWindow.invokeMethod(
      extensionLogWindowId.value,
      "getMethods",
    );

    return List<dynamic>.from(methods)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // 处理待执行的方法
  Future<void> _handleMethods() async {
    final methods = await _getMethods();
    for (final call in methods) {
      if (call["method"] == "getInstalledExtensions") {
        _invokeMethodResult(
          call["key"],
          ExtensionUtils.extensions.values
              .toList()
              .map((e) => e.toJson())
              .toList(),
        );
      }

      if (call["method"] == "debugExecute") {
        final arguments = call["arguments"];
        final extension = ExtensionUtils.extensions[arguments["package"]];
        final method = arguments["method"];
        final runtime = await RuntimeHelper.instance.getRuntime(extension!);
        try {
          final jsResult = await runtime.handlePromise(
            await runtime.evaluateAsync('stringify(()=>{return $method})'),
          );
          final result = jsResult.stringResult;
          _invokeMethodResult(
            call["key"],
            result,
          );
        } catch (e) {
          _invokeMethodResult(
            call["key"],
            e.toString(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
