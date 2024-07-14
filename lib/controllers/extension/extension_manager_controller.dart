import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';

class ExtensionManagerController extends GetxController {
  List<Extension> extensions = <Extension>[].obs;
  RxMap<String, String> errors = <String, String>{}.obs;
  RxBool isInstallLoading = false.obs;
  bool needRefresh = true;
  bool isPageOpen = false;
  ExtensionType? lastType;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  @override
  void onReady() {
    isPageOpen = true;
    if (needRefresh) {
      onRefresh();
    }
    super.onReady();
  }

  @override
  void dispose() {
    isPageOpen = false;
    super.dispose();
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
    errors.clear();
    extensions.addAll(ExtensionUtils.extensions.values);
    errors.addAll(ExtensionUtils.extensionErrorMap);
  }

  callRefresh() {
    if (isPageOpen) {
      onRefresh();
    } else {
      needRefresh = true;
    }
  }
}
