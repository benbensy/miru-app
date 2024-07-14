import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/data/services/extension_helper.dart';
import 'package:miru_app/models/extension.dart';
import 'package:super_paging/super_paging.dart';

class ComicMortySource extends PagingSource<int, String> {
  ComicMortySource({
    required this.extension,
    required this.playList,
    required this.mangaWatch,
    required this.pageWatch,
  });

  final ValueChanged<int> pageWatch;
  final ValueChanged<ExtensionMangaWatch> mangaWatch;
  final Extension extension;
  final List<ExtensionEpisode> playList;
  int jumpPage = -1;

  @override
  Future<LoadResult<int, String>> load(LoadParams<int> params) async {
    try {
      var loadKey = params.key ?? 0;
      if (jumpPage > -1) {
        loadKey = jumpPage;
        jumpPage = -1;
      }

      var currentPlayUrl = playList[loadKey].url;
      var result = await ExtensionHelper(extension).watch(currentPlayUrl)
          as ExtensionMangaWatch;
      var list = [
        if (loadKey > 0) "[next_chapter] ${playList[loadKey].name}",
        ...result.urls,
        "[last_chapter] ${playList[loadKey].name}",
      ];
      mangaWatch.call(result);
      pageWatch.call(loadKey);
      return LoadResult.page(
        nextKey: ++loadKey,
        //prevKey: --loadKey,
        items: list,
      );
    } catch (e) {
      return LoadResult.error(e);
    }
  }
}
