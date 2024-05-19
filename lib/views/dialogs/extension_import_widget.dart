import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/router.dart';
import 'package:miru_app/utils/theme_utils.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:url_launcher/url_launcher.dart';

class ExtensionImportWidget extends StatelessWidget {
  String url = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformWidget(
          mobileWidget: TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              labelText: 'extension.import.url-label'.i18n,
              hintText: "https://example.com/extension.js",
            ),
            onChanged: (value) {
              url = value;
            },
          ),
          desktopWidget: Row(
            children: [
              Expanded(
                  child: fluent.TextBox(
                placeholder: 'extension.import.url-label'.i18n,
                onChanged: (value) {
                  url = value;
                },
              )),
              const SizedBox(width: 8),
              fluent.Tooltip(
                message: 'extension.import.extension-dir'.i18n,
                child: fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.fabric_folder),
                  onPressed: () async {
                    RouterUtils.pop();
                    // 定位目录
                    final dir = ExtensionUtils.extensionsDir;
                    final uri = Uri.directory(dir);
                    await launchUrl(uri);
                  },
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(fluent.FluentIcons.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "extension.import.tips".i18n,
                softWrap: true,
              ),
            )
          ],
        ),
        (Platform.isAndroid || Platform.isIOS)
            ? _mobileAction(context)
            : _desktopAction(context)
      ],
    );
  }

  Widget _desktopAction(BuildContext context) {
    return Column(
      children: [
        PlatformFilledButton(
          onPressed: () async {
            RouterUtils.pop();
            await ExtensionUtils.install(url, context);
          },
          child: Text('extension.import.import-by-url'.i18n),
        ),
        PlatformFilledButton(
          child: Text('extension.import.import-by-local'.i18n),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['js'],
            );
            if (result == null) {
              return;
            }
            final path = result.files.single.path;
            if (path == null) {
              return;
            }
            final script = File(path).readAsStringSync();
            await ExtensionUtils.installByScript(script, context);
            RouterUtils.pop();
          },
        ),
        PlatformButton(
          onPressed: () {
            RouterUtils.pop();
          },
          child: Text('common.cancel'.i18n),
        ),
      ],
    );
  }

  Widget _mobileAction(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            child: Container(
              height: 48,
              width: double.infinity,
              color: context.primaryColor,
              child: Center(
                child: Text(
                  style: TextStyle(
                    color: context.backgroundColor,
                    fontSize: 14,
                  ),
                  'extension.import.import-by-url'.i18n,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            onTap: () async {
              RouterUtils.pop();
              await ExtensionUtils.install(url, context);
            },
          ),
          const SizedBox(
            height: 1,
          ),
          InkWell(
            child: Container(
              width: double.infinity,
              height: 48,
              color: context.primaryColor,
              child: Center(
                child: Text(
                  'extension.import.import-by-local'.i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.backgroundColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['js'],
              );
              if (result == null) {
                return;
              }
              final path = result.files.single.path;
              if (path == null) {
                return;
              }
              final script = File(path).readAsStringSync();
              await ExtensionUtils.installByScript(script, context);
              RouterUtils.pop();
            },
          ),
          const SizedBox(
            height: 1,
          ),
          InkWell(
            child: Container(
              height: 48,
              width: double.infinity,
              color: context.primaryColor,
              child: Center(
                child: Text(
                  'common.cancel'.i18n,
                  style: TextStyle(
                    color: context.backgroundColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            onTap: () {
              RouterUtils.pop();
            },
          ),
        ],
      ),
    );
  }
}
