import 'package:get/get.dart';
import 'package:miru_app/views/pages/update/update_controller.dart';

class UpdateBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpdateController());
  }
}
