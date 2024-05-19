import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_save_state_widget.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/controllers/home_controller.dart';
import 'package:miru_app/models/history.dart';
import 'package:miru_app/utils/theme_utils.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.resents.isNotEmpty) ...[
                HomeRecent(
                  data: controller.resents,
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: Get.width / 1.5,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: controller.pageController,
                  itemBuilder: (context, index) {
                    EdgeInsets pd;
                    if (index == 0) {
                      pd = const EdgeInsets.only(
                          left: 16, right: 8, top: 16, bottom: 16);
                    } else if (index == controller.resents.length - 1) {
                      pd = const EdgeInsets.only(
                          left: 8, right: 16, top: 16, bottom: 16);
                    } else {
                      pd = const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16);
                    }
                    return Padding(
                      padding: pd,
                      child: ParallaxImage(
                        history: controller.resents[index],
                        horizontalSlide:
                            (index - controller.page).clamp(-1, 1).toDouble(),
                      ),
                    );
                  },
                  itemCount: controller.resents.length,
                ),
              ),
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

class ParallaxImage extends StatelessWidget {
  final History history;
  final double horizontalSlide;

  const ParallaxImage({
    super.key,
    required this.history,
    required this.horizontalSlide,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1 - horizontalSlide.abs();
    final size = MediaQuery.of(context).size;

    return SizedBox(
      // width: (size.width / 2)-(size.width / 2) * ((scale * 0.8) + 0.8),
      //height: size.height * ((scale * 0.2) + 0.2),
      height: double.infinity,
      width: (size.width / 3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(48)),
            child: ExtendedImage.network(
              history.cover!,
              fit: BoxFit.cover,
              alignment: Alignment(horizontalSlide, 1),
              cache: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    history.title,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
