import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';

class ExtensionBrowseController extends GetxController {
  List<Extension> extensions = <Extension>[].obs;
  ExtensionType? lastType;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  filterExtension(ExtensionType? type) {
    lastType = type;
    if (type == null) {
      onRefresh();
    } else {
      _filterExtData(type);
    }
  }

  void _filterExtData(ExtensionType? type) {
    extensions.clear();
    var filter = ExtensionUtils.extensions.values
        .where((element) => element.type == type);
    extensions.addAll(filter);
  }

  onRefresh() async {
    extensions.clear();
    extensions.addAll(ExtensionUtils.extensions.values);
  }
}
