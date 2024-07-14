import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/theme_utils.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/pages/search/extension_searcher_page.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class ExtensionBrowseTile extends StatefulWidget {
  const ExtensionBrowseTile(this.extension, {super.key});

  final Extension extension;

  @override
  State<ExtensionBrowseTile> createState() => _ExtensionTileState();
}

class _ExtensionTileState extends State<ExtensionBrowseTile> {
  final fluent.FlyoutController moreFlyoutController =
      fluent.FlyoutController();

  Widget _buildMobile(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.primaryContainerColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: CacheNetWorkImagePic(
            widget.extension.icon ?? '',
            key: ValueKey(widget.extension.icon),
            fit: BoxFit.contain,
            fallback: const Icon(Icons.extension),
          ),
        ),
      ),
      title: Text(widget.extension.name),
      subtitle: Text(
        '${widget.extension.version}  ${ExtensionUtils.typeToString(widget.extension.type)} ',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        Get.to(ExtensionSearcherPage(
          package: widget.extension.package,
        ));
      },
      contentPadding: const EdgeInsets.only(left: 16),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.Card(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // extension icon
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: CacheNetWorkImagePic(
                      widget.extension.icon ?? '',
                      key: ValueKey(widget.extension.icon),
                      fit: BoxFit.contain,
                      fallback: const Icon(fluent.FluentIcons.add_in),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.extension.name,
                        style: const TextStyle(
                          fontSize: 17,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.extension.author,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(widget.extension.version)),
          Expanded(
            child: Text(ExtensionUtils.typeToString(widget.extension.type)),
          ),
          const Spacer(),
          fluent.IconButton(
              // child: Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 2,
              //   ),
              //   child: Text('common.settings'.i18n),
              // ),
              icon: const Icon(fluent.FluentIcons.settings),
              onPressed: () {
                router.push(Uri(
                  path: "/search_extension",
                  queryParameters: {
                    "package": widget.extension.package,
                  },
                ).toString());
              }),
          const SizedBox(width: 8),
          fluent.FlyoutTarget(
            controller: moreFlyoutController,
            child: fluent.IconButton(
              icon: const Icon(fluent.FluentIcons.more),
              onPressed: () {
                moreFlyoutController.showFlyout(
                  autoModeConfiguration: fluent.FlyoutAutoConfiguration(
                    preferredMode: fluent.FlyoutPlacementMode.bottomLeft,
                  ),
                  builder: (context) {
                    return fluent.MenuFlyout(
                      items: [
                        fluent.MenuFlyoutItem(
                          leading: const Icon(fluent.FluentIcons.code),
                          text: Text('extension.edit-code'.i18n),
                          onPressed: () async {
                            fluent.Flyout.of(context).close();
                            launchUrl(path.toUri(
                              '${ExtensionUtils.extensionsDir}/${widget.extension.package}.js',
                            ));
                          },
                        ),
                        fluent.MenuFlyoutItem(
                          leading: const Icon(fluent.FluentIcons.delete),
                          text: Text('common.uninstall'.i18n),
                          onPressed: () {
                            ExtensionUtils.uninstall(widget.extension.package);
                            fluent.Flyout.of(context).close();
                          },
                        ),
                      ],
                    );
                  },
                  barrierDismissible: true,
                  dismissWithEsc: true,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}
