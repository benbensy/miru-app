import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/i18n.dart';

class FilterExtensionDialog extends StatelessWidget {
  const FilterExtensionDialog(this.selected, this.changed, {super.key});

  final ExtensionType? selected;
  final ValueChanged<ExtensionType?> changed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ExtensionType?>(
              segments: [
                ButtonSegment(
                  value: null,
                  label: Text('common.show-all'.i18n),
                ),
                ButtonSegment(
                  value: ExtensionType.bangumi,
                  label: Text('extension-type.video'.i18n),
                ),
                ButtonSegment(
                  value: ExtensionType.manga,
                  label: Text('extension-type.comic'.i18n),
                ),
                ButtonSegment(
                  value: ExtensionType.fikushon,
                  label: Text('extension-type.novel'.i18n),
                ),
              ],
              selected: <ExtensionType?>{selected},
              onSelectionChanged: (value) {
                debugPrint(value.first.toString());
                changed.call(value.first);
                Get.back();
              },
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, ExtensionType? selected,
      ValueChanged<ExtensionType?> changed) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: FilterExtensionDialog(selected, changed),
        );
      },
    );
  }
}
