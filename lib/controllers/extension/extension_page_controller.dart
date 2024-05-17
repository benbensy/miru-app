import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/views/pages/extension/extension_browse_page.dart';
import 'package:miru_app/views/pages/search/search_page.dart';

class ExtensionPageController extends GetxController {
  final PageController pageController = PageController();

  final List<Widget> pages = [
    const SearchPage(),
    const ExtensionBrowsePage(),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
