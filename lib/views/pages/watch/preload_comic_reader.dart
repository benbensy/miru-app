import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_binding_widget.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/pages/webview_page.dart';
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
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                WebViewPage(
                  extension: extension,
                  url: detailUrl,
                ),
              );
            },
            icon: const Icon(Icons.public),
          ),
        ],
      ),
      body: PagingListView(
        pager: controller.pager,
        itemBuilder: (BuildContext context, int index) {
          final item = controller.pager.items.elementAt(index);
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
      ),
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
