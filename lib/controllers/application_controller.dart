import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/miru_storage.dart';

class ApplicationController extends GetxController {
  static get find => Get.find();

  String themeText = "system";

  @override
  void onInit() {
    themeText = MiruStorage.getSetting(SettingKey.theme);
    super.onInit();
  }

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    if (themeText == "black") {
      return blackTheme();
    } else {
      var enableDyColor = MiruStorage.getSetting(SettingKey.dynamicColor);
      var themeAccent = MiruStorage.getSetting(SettingKey.themeAccent);
      final scheme = lightColorScheme ??
          ColorScheme.fromSeed(seedColor: Color(themeAccent));
      if (enableDyColor) {
        return ThemeData(
          colorScheme: scheme,
        );
      } else {
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(themeAccent)),
        );
      }
    }
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    var themeAccent = MiruStorage.getSetting(SettingKey.themeAccent);
    var enableDyColor = MiruStorage.getSetting(SettingKey.dynamicColor);
    final scheme = darkColorScheme ??
        ColorScheme.fromSeed(
          seedColor: Color(themeAccent),
          brightness: Brightness.dark,
        );
    if (enableDyColor) {
      return ThemeData(
        colorScheme: scheme,
      );
    } else {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(themeAccent),
          brightness: Brightness.dark,
        ),
      );
    }
  }

  ThemeData blackTheme() {
    return ThemeData.dark(
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: Colors.black,
      dialogBackgroundColor: Colors.black,
      primaryColor: Colors.black,
      hintColor: Colors.black,
      primaryColorDark: Colors.black,
      primaryColorLight: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onBackground: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        secondary: Colors.grey,
        surface: Colors.black,
        background: Colors.black,
        onPrimary: Colors.black,
        primaryContainer: Color.fromARGB(255, 31, 31, 31),
        surfaceTint: Colors.black,
      ),
    );
  }

  ThemeMode get theme {
    switch (themeText) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "black":
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  changeTheme(String mode) {
    MiruStorage.setSetting(SettingKey.theme, mode);
    themeText = mode;
    Get.forceAppUpdate();
  }
}
