import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'extension_import_widget.dart';

class ExtensionDialogs {
  // 导入扩展对话框
  static importDialog(BuildContext context) {
    showPlatformDialog(
        actions: null,
        context: context,
        title: 'extension.import.title'.i18n,
        maxWidth: 500,
        content: ExtensionImportWidget());
  }

  // 加载错误对话框
  static loadErrorDialog(BuildContext context, Map<String, String> errors) {
    showPlatformDialog(
      context: context,
      title: 'extension.error-dialog'.i18n,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 输出key 和 value
            for (final e in errors.entries)
              PlatformWidget(
                mobileWidget: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "${e.key}: ${e.value}",
                    ),
                  ),
                ),
                desktopWidget: fluent.Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${e.key}: ${e.value}",
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        PlatformButton(
          onPressed: () {
            RouterUtils.pop();
          },
          child: Text('common.confirm'.i18n),
        ),
      ],
    );
  }
}
