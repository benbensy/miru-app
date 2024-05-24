import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_common_widget.dart';
import 'package:miru_app/views/pages/watch/preload_comic_reader_controller.dart';
import 'package:miru_app/views/pages/webview_page.dart';
import 'package:miru_app/views/widgets/watch/playlist.dart';

class ComicControlPanelHead
    extends GetCommonWidget<PreloadComicReaderController> {
  const ComicControlPanelHead(this.title, {super.key});

  final String title;

  @override
  Widget buildWidget(BuildContext context) {
    return SizedBox(
      height:
          AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
      child: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                WebViewPage(
                  extension: controller.extension,
                  url: controller.detailUrl,
                ),
              );
            },
            icon: const Icon(Icons.public),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (context) {
                  return PlayList(
                    title: title,
                    list: controller.playList.map((e) => e.name).toList(),
                    selectIndex: controller.currentPage,
                    onChange: (value) {
                      controller.jumpPage(value);
                      Get.back();
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.list_alt_outlined),
          ),
        ],
      ).animate().fade(),
    );
  }
}
