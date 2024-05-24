import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:super_paging/super_paging.dart';

import 'comic_morty_source.dart';

class PreloadComicReaderController extends GetxController {
  final List<ExtensionEpisode> playList;
  final Extension extension;
  ExtensionMangaWatch? currentMange;
  String detailUrl;
  int currentPage = 1;
  int startPage;

  final isShowControlPanel = false.obs;

  late final pager = Pager(
    initialKey: 1,
    config: const PagingConfig(pageSize: 60, prefetchIndex: 4),
    pagingSourceFactory: () => ComicMortySource(
      extension: extension,
      playList: playList,
      startPage: startPage,
      mangaWatch: (mange) {
        currentMange = mange;
      },
      pageWatch: (index) {
        currentPage = index;
      },
    ),
  );

  PreloadComicReaderController({
    required this.playList,
    required this.extension,
    required this.startPage,
    required this.detailUrl,
  });

  @override
  void onClose() {
    pager.dispose();
    super.onClose();
  }
}
