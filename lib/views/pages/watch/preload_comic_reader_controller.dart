import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:super_paging/super_paging.dart';

import 'comic_morty_source.dart';

class PreloadComicReaderController extends GetxController {
  final List<ExtensionEpisode> playList;
  final Extension extension;
  ExtensionMangaWatch? currentMange;
  int startPage;

  late final pager = Pager(
    initialKey: 1,
    config: PagingConfig(pageSize: playList.length, prefetchIndex: 4),
    pagingSourceFactory: () => ComicMortySource(
      extension: extension,
      playList: playList,
      startPage: startPage,
      mangaWatch: (mange) {
        currentMange = mange;
      },
    ),
  );

  PreloadComicReaderController({
    required this.playList,
    required this.extension,
    required this.startPage,
  });
}
