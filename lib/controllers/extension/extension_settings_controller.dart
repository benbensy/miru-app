import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/models/extension_setting.dart';
import 'package:miru_app/data/services/database_service.dart';
import 'package:miru_app/utils/extension.dart';

class ExtensionSettingsPageController extends GetxController {
  ExtensionSettingsPageController(this.package);
  final String package;

  final Rx<Extension?> extension = Rx(null);

  final List<ExtensionSetting> settings = <ExtensionSetting>[].obs;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
  }

  onRefresh() async {
    extension.value = ExtensionUtils.extensions[package];
    settings.clear();
    settings.addAll(await DatabaseService.getExtensionSettings(package));
  }
}
