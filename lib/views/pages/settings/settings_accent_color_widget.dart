import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/base/widget/get_common_widget.dart';
import 'package:miru_app/controllers/application_controller.dart';
import 'package:miru_app/controllers/settings_controller.dart';
import 'package:miru_app/utils/miru_storage.dart';

class SettingsAccentColorWidget extends GetCommonWidget<SettingsController> {
  const SettingsAccentColorWidget({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.colors.length,
        controller: controller.scrollController,
        itemBuilder: (c, index) {
          return Obx(
            () => Padding(
              padding: const EdgeInsets.all(8),
              child: _colorItem(
                Color(controller.colors[index]),
                index == controller.selectThemeColorIndex.value,
                () {
                  MiruStorage.setSetting(
                      SettingKey.themeAccent, controller.colors[index]);
                  controller.selectThemeColorIndex.value = index;
                  var appController = Get.find<ApplicationController>();
                  appController.changeTheme(appController.themeText);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _colorItem(Color color, bool isSelect, GestureTapCallback onTap) {
    return InkResponse(
      onTap: onTap,
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
    );
  }
}
