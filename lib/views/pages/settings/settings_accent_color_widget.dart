import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_common_widget.dart';
import 'package:miru_app/controllers/settings_controller.dart';
import 'package:miru_app/utils/theme_utils.dart';
import 'package:miru_app/views/widgets/gaps.dart';

class SettingsAccentColorWidget extends GetCommonWidget<SettingsController> {
  const SettingsAccentColorWidget({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    var colorLength = controller.colors.length;
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Platform.isAndroid ? colorLength + 1 : colorLength,
        controller: controller.scrollController,
        itemBuilder: (c, index) {
          return Obx(
            () => Padding(
              padding: _itemPadding(index),
              child: _buildColorItem(
                c,
                index,
                index == controller.selectThemeColorIndex.value,
                () {
                  controller.changeAccent(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorItem(BuildContext context, int index, bool isSelect,
      GestureTapCallback onTap) {
    if (Platform.isAndroid && index == 0) {
      return _dyColorItem(context, isSelect, onTap);
    } else {
      var offset = Platform.isAndroid ? 1 : 0;
      Color color = Color(controller.colors[index - offset]);
      return _colorItem(color, isSelect, onTap);
    }
  }

  EdgeInsets _itemPadding(int index) {
    if (index == 0) {
      return const EdgeInsets.fromLTRB(16, 8, 8, 8);
    } else if (index == controller.colors.length - 1) {
      return const EdgeInsets.fromLTRB(8, 8, 16, 8);
    } else {
      return const EdgeInsets.all(8);
    }
  }

  Widget _dyColorItem(
      BuildContext context, bool isSelect, GestureTapCallback onTap) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/icon/dy_md.png',
                fit: BoxFit.fill,
              ),
              isSelect
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : Gaps.empty,
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorItem(Color color, bool isSelect, GestureTapCallback onTap) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: isSelect
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
