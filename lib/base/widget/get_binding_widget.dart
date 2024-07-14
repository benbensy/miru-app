import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GetBindingWidget<T extends GetxController>
    extends StatefulWidget {
  const GetBindingWidget({super.key});

  final String? tag = null;

  T get controller => GetInstance().find<T>(tag: tag);

  @protected
  Widget build(BuildContext context);

  @protected
  Bindings? binding();

  @override
  AutoDisposeState createState() => AutoDisposeState<T>();
}

class AutoDisposeState<S extends GetxController>
    extends State<GetBindingWidget> {
  AutoDisposeState();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<S>(builder: (controller) {
      return widget.build(context);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.binding()?.dependencies();
  }

  @override
  void dispose() {
    Get.delete<S>();
    super.dispose();
  }
}
