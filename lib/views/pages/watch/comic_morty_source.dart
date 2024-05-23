import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/data/services/extension_helper.dart';
import 'package:miru_app/models/extension.dart';
import 'package:super_paging/super_paging.dart';

class ComicMortySource extends PagingSource<int, String> {
  var _loadKey = 1;

  ComicMortySource(
      {required this.extension,
      required this.playList,
      required this.mangaWatch});

  final ValueChanged<ExtensionMangaWatch> mangaWatch;
  final Extension extension;
  final List<ExtensionEpisode> playList;

  @override
  Future<LoadResult<int, String>> load(LoadParams<int> params) async {
    try {
      var currentPlayUrl = playList[_loadKey].url;
      var result = await ExtensionHelper(extension).watch(currentPlayUrl) as ExtensionMangaWatch;
      mangaWatch.call(result);
      return LoadResult.page(
        nextKey: _loadKey++,
        items: result.urls,
      );
    } catch (e) {
      return LoadResult.error(e);
    }
  }
}
