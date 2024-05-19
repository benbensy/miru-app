import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_save_state_widget.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/views/widgets/home/home_favorites.dart';
import 'package:miru_app/views/widgets/home/home_recent.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class HomePage extends GetSaveWidget<HomePageController> {
  const HomePage({super.key});

  @override
  Bindings? binding() {
    return BindingsBuilder(() {
      Get.lazyPut(() => HomePageController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobileHome,
      desktopBuilder: _buildDesktopHome,
    );
  }

  Widget _buildContent() {
    return Obx(
      () {
        if (controller.resents.isEmpty &&
            controller.favorites.values.every((element) => element.isEmpty)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "（＞人＜；）",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "home.no-record".i18n,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.resents.isNotEmpty) ...[
                  HomeRecent(
                    data: controller.resents,
                  ),
                  const SizedBox(height: 16),
                ],
                if (controller.favorites.isNotEmpty) ...[
                  HomeFavorites(
                    type: ExtensionType.bangumi,
                    data: controller.favorites[ExtensionType.bangumi]!,
                  ),
                  HomeFavorites(
                    type: ExtensionType.manga,
                    data: controller.favorites[ExtensionType.manga]!,
                  ),
                  HomeFavorites(
                    type: ExtensionType.fikushon,
                    data: controller.favorites[ExtensionType.fikushon]!,
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileHome(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("common.home".i18n),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildDesktopHome(BuildContext context) {
    return _buildContent();
  }
}
