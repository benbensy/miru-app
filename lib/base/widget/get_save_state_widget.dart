import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GetSaveWidget<T extends GetxController> extends StatefulWidget {
  const GetSaveWidget({super.key});

  final String? tag = null;

  T get controller => GetInstance().find<T>(tag: tag);

  ///Get 局部更新字段
  get updateId => null;

  ///widget生命周期
  get lifecycle => null;

  @protected
  Widget build(BuildContext context);

  @override
  AutoDisposeState createState() => AutoDisposeState<T>();
}

class AutoDisposeState<S extends GetxController> extends State<GetSaveWidget>
    with AutomaticKeepAliveClientMixin<GetSaveWidget>, WidgetsBindingObserver {
  AutoDisposeState();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<S>(
        id: widget.updateId,
        builder: (controller) {
          return widget.build(context);
        });
  }

  @override
  void initState() {
    super.initState();
    if (widget.lifecycle != null) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    Get.delete<S>();
    if (widget.lifecycle != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (widget.lifecycle != null) {
      widget.lifecycle(state);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
