import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/theme_utils.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayList extends fluent.StatelessWidget {
  const PlayList({
    super.key,
    required this.title,
    required this.list,
    required this.selectIndex,
    required this.onChange,
  });

  final String title;
  final List<String> list;
  final int selectIndex;
  final Function(int) onChange;

  Widget _buildMobile(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 1.0,
      minChildSize: 0.2,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Padding(
          padding: const EdgeInsets.only(top: 48, right: 16, left: 16),
          child: ListView.builder(
            controller: scrollController,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final contact = list[index];
              return PlaylistAndroidTile(
                title: contact,
                selected: list[selectIndex] == contact,
                onTap: () {
                  onChange(index);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: list.length,
      initialScrollIndex: selectIndex,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final contact = list[index];
        return fluent.ListTile.selectable(
          title: Text(contact),
          onPressed: () {
            onChange(index);
          },
          selected: list[selectIndex] == contact,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}

class PlaylistAndroidTile extends StatelessWidget {
  const PlaylistAndroidTile({
    super.key,
    required this.title,
    required this.onTap,
    required this.selected,
  });

  final String title;
  final Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              selected ? context.primaryColor : context.dialogBackgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
