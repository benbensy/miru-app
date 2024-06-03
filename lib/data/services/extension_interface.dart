import 'package:miru_app/models/extension.dart';

abstract class ExtensionInterface {
  Future<ExtensionDetail> detail(String url);

  Future<List<ExtensionListItem>> latest(int page);

  Future<List<ExtensionListItem>> search(
    String kw,
    int page, {
    Map<String, List<String>>? filter,
  });

  Future<Map<String, ExtensionFilter>?> createFilter({
    Map<String, List<String>>? filter,
  });

  Future<Object?> watch(String url);

  Future<String> checkUpdate(url);
}
