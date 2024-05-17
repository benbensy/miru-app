import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_binding_widget.dart';
import 'package:miru_app/controllers/extension/extension_browse_controller.dart';
import 'package:miru_app/controllers/extension/extension_page_controller.dart';
import 'package:miru_app/utils/i18n.dart';

class ExtensionPage extends GetBindingWidget<ExtensionPageController> {
  const ExtensionPage({super.key});

  @override
  Bindings? binding() {
    return BindingsBuilder(() {
      Get.lazyPut(() => ExtensionBrowseController());
      Get.lazyPut(() => ExtensionPageController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: 'common.browse'.i18n),
              Tab(text: 'extension.extension-manager'.i18n),
            ],
            onTap: (value) {
              controller.pageController.jumpToPage(value);
            },
          ),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: controller.pages,
          ),
        ),
      ),
    );
  }
}
