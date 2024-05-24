import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_save_state_widget.dart';
import 'package:miru_app/controllers/extension/extension_page_controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/dialogs/extension_dialogs.dart';
import 'package:miru_app/views/widgets/messenger.dart';

import 'extension_repo_page.dart';

class ExtensionPage extends GetSaveWidget<ExtensionPageController> {
  const ExtensionPage({super.key});

  @override
  Bindings? binding() {
    return BindingsBuilder(() {
      Get.lazyPut(() => ExtensionPageController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: _appbarAction(context),
            title: Text("common.extension".i18n),
          ),
          body: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'common.browse'.i18n),
                  Tab(text: 'extension.extension-manager'.i18n),
                ],
                onTap: (value) {
                  controller.pageController.jumpToPage(value);
                },
              ),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.pageController,
                  children: controller.pages,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _appbarAction(BuildContext context) {
    var bro = [
      IconButton(
        onPressed: () {
          showPlatformSnackbar(
            context: context,
            title: "Tip",
            content: "Global search is temporarily unavailable",
          );
          // Get.to(
          //   () => const SearchPage(),
          // );
        },
        icon: const Icon(Icons.search),
      ),
    ];
    var ext = [
      if (controller.errors.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.error),
          onPressed: () =>
              ExtensionDialogs.loadErrorDialog(context, controller.errors),
        ),
      IconButton(
        onPressed: () => ExtensionDialogs.importDialog(context),
        icon: const Icon(
          Icons.add_rounded,
          size: 32,
        ),
      ),
      IconButton(
        onPressed: () {
          Get.to(
            () => const ExtensionRepoPage(),
          );
        },
        icon: const Icon(Icons.download),
      )
    ];
    if (controller.currentPage.value == 0) {
      return bro;
    } else {
      return ext;
    }
  }
}
