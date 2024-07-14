import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_save_state_widget.dart';
import 'package:miru_app/controllers/extension/extension_browse_controller.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/dialogs/filter_extension_dialog.dart';
import 'package:miru_app/views/widgets/extension/extension_browse_title.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ExtensionBrowsePage extends GetSaveWidget<ExtensionBrowseController> {
  const ExtensionBrowsePage({super.key});

  @override
  Bindings? binding() {
    return BindingsBuilder(() {
      Get.lazyPut(() => ExtensionBrowseController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Obx(() {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            FilterExtensionDialog.show(
              context,
              controller.lastType,
              (type) {
                controller.filterExtension(type);
              },
            );
          },
          child: const Icon(Icons.filter_alt_outlined),
        ),
        body: ListView.builder(
          itemCount: controller.extensions.length,
          itemBuilder: (BuildContext context, int index) {
            if (controller.extensions.isEmpty) {
              SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('common.no-extension'.i18n),
                  ],
                ),
              );
            }
            var ext = controller.extensions[index];
            return ExtensionBrowseTile(ext);
          },
        ),
      );
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Column(
          children: [
            Row(
              children: [
                Text(
                  'common.extension'.i18n,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.extensions.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('common.no-extension'.i18n),
                    const SizedBox(height: 8),
                    fluent.FilledButton(
                      child: Text(
                        'common.extension-repo'.i18n,
                      ),
                      onPressed: () {
                        router.push('/extension_repo');
                      },
                    )
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final ext in controller.extensions)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExtensionBrowseTile(ext),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
