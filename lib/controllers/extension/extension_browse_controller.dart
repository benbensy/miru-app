import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/data/services/extension_service.dart';

class ExtensionBrowseController extends GetxController {
  List<ExtensionService> runtimes = <ExtensionService>[].obs;
  RxMap<String, String> errors = <String, String>{}.obs;
  RxBool isInstallloading = false.obs;
  bool needRefresh = true;
  bool isPageOpen = false;
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
    runtimes.clear();
    var filter = ExtensionUtils.runtimes.values
        .where((element) => element.extension.type == type);
    runtimes.addAll(filter);
  }

  onRefresh() async {
    runtimes.clear();
    errors.clear();
    runtimes.addAll(ExtensionUtils.runtimes.values);
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
