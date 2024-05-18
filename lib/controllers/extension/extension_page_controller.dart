import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/views/pages/extension/extension_browse_page.dart';
import 'package:miru_app/views/pages/extension/extension_manager_page.dart';

class ExtensionPageController extends GetxController {
  RxMap<String, String> errors = <String, String>{}.obs;
  RxInt currentPage = 0.obs;
  final PageController pageController = PageController();

  final List<Widget> pages = [
    const ExtensionBrowsePage(),
    const ExtensionManagerPage()
  ];

  @override
  void onInit() {
    errors.clear();
    errors.addAll(ExtensionUtils.extensionErrorMap);
    super.onInit();
  }

  @override
  void onReady() {
    pageController.addListener(() {
      currentPage.value = pageController.page?.toInt() ?? 0;
      update();
    });
    super.onReady();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
