import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GetCommonWidget<T extends GetxController>
    extends StatelessWidget {
  const GetCommonWidget({super.key});

  final String? tag = null;

  get updateId => null;

  T get controller => GetInstance().find<T>(tag: tag);

  @protected
  void initState(GetBuilderState<T> state) {}

  @protected
  void didChangeDependencies(GetBuilderState<T> state) {}

  @protected
  void didUpdateWidget(GetBuilder oldWidget, GetBuilderState<T> state) {}

  @protected
  void dispose(GetBuilderState<T> state) {}

  @protected
  Widget buildWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      id: updateId,
      init: controller,
      initState: (state) {
        initState(state);
      },
      autoRemove: true,
      didChangeDependencies: (state) {
        didChangeDependencies(state);
      },
      didUpdateWidget: (oldWidget, state) {
        didUpdateWidget(oldWidget, state);
      },
      dispose: (state) {
        dispose(state);
      },
      builder: (controller) {
        return buildWidget(context);
      },
    );
  }
}
