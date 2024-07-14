import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get primaryContainerColor =>
      Theme.of(this).colorScheme.primaryContainer;

  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get dialogBackgroundColor => Theme.of(this).canvasColor;
}
