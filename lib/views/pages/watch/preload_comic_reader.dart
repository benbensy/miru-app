import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_binding_widget.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/pages/watch/comic_control_panel_footer.dart';
import 'package:miru_app/views/pages/watch/comic_control_panel_head.dart';
import 'package:miru_app/views/widgets/cache_network_image.dart';
import 'package:miru_app/views/widgets/progress.dart';
import 'package:super_paging/super_paging.dart';

import 'preload_comic_reader_controller.dart';

class PreloadComicReader
    extends GetBindingWidget<PreloadComicReaderController> {
  const PreloadComicReader({
    super.key,
    required this.title,
    required this.playList,
    required this.detailUrl,
    required this.playerIndex,
    required this.episodeGroupId,
    required this.extension,
    required this.anilistID,
    this.cover,
  });

  final String title;
  final List<ExtensionEpisode> playList;
  final String detailUrl;
  final int playerIndex;
  final int episodeGroupId;
  final Extension extension;
  final String? cover;
  final String anilistID;

  @override
  Bindings? binding() {
    return BindingsBuilder(() {
      Get.lazyPut(
        () => PreloadComicReaderController(
          extension: extension,
          playList: playList,
          startPage: playerIndex,
          detailUrl: detailUrl,
        ),
      );
    });
  }

  _buildComicContent() {
    return Stack(
      children: [
        _comicListContent(),
        Positioned(
          top: 140,
          bottom: 140,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              controller.isShowControlPanel.value =
                  !controller.isShowControlPanel.value;
            },
          ),
        ),
        Positioned(
          child: Obx(
            () => Visibility(
              visible: controller.isShowControlPanel.value,
              child: ComicControlPanelHead(title),
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: Obx(
            () => Visibility(
              visible: controller.isShowControlPanel.value,
              child: const ComicControlPanelFooter(),
            ),
          ),
        ),
      ],
    );
  }

  _comicListContent() {
    return PagingListView(
      pager: controller.pager,
      itemBuilder: (BuildContext context, int index) {
        final item = controller.pager.items.elementAt(index);
        if (item.startsWith("[last_chapter]") ||
            item.startsWith("[next_chapter]")) {
          var chapter = item
              .replaceAll("[last_chapter]", "common.last-chapter".i18n)
              .replaceAll("[next_chapter]", "common.next-chapter".i18n);
          return Container(
            width: double.infinity,
            height: Get.height / 12,
            color: Colors.black,
            child: Center(
              child: Text(
                chapter,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        // var c = [Colors.amber, Colors.blue, Colors.deepPurpleAccent];
        // return Container(
        //   color: c[index % 2],
        //   width: double.infinity,
        //   height: 300,
        // );
        return CacheNetWorkImagePic(
          item,
          fit: BoxFit.fitWidth,
          placeholder: _buildPlaceholder(context),
          headers: controller.currentMange?.headers,
        );
      },
      emptyBuilder: (BuildContext context) {
        return const Center(
          child: Text('No more'),
        );
      },
      errorBuilder: (BuildContext context, Object? error) {
        return Center(child: Text('$error'));
      },
      loadingBuilder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildComicContent(),
    );
  }

  _buildPlaceholder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Center(
          child: ProgressRing(),
        ),
      ),
    );
  }
}
