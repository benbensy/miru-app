import 'package:flutter/material.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:miru_app/base/widget/get_binding_widget.dart';
import 'package:miru_app/base/widget/get_save_state_widget.dart';
import 'package:miru_app/views/pages/update/update_bindings.dart';
import 'package:miru_app/views/pages/update/update_controller.dart';

class UpdatePage extends GetSaveWidget<UpdateController> {
  const UpdatePage({super.key});

  @override
  Bindings? binding() {
    return UpdateBindings();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("TODO"),
    );
  }
}
