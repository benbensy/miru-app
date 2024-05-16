import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_binding_widget.dart';
import 'package:miru_app/controllers/extension/extension_browse_controller.dart';
import 'package:miru_app/controllers/extension/extension_page_controller.dart';

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
            tabs: const [
              Tab(text: 'search'),
              Tab(text: 'extension-type'),
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
