import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/services/extension_helper.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/router/router.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/button.dart';
import 'package:miru_app/views/widgets/extension_item_card.dart';
import 'package:miru_app/views/widgets/infinite_scroller.dart';
import 'package:miru_app/views/widgets/messenger.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';
import 'package:miru_app/views/widgets/search_appbar.dart';

class ExtensionSearcherPage extends StatefulWidget {
  const ExtensionSearcherPage({
    super.key,
    required this.package,
    this.keyWord,
  });

  final String package;
  final String? keyWord;

  @override
  fluent.State<ExtensionSearcherPage> createState() =>
      _ExtensionSearcherPageState();
}

class _ExtensionSearcherPageState extends fluent.State<ExtensionSearcherPage> {
  late Extension _extension;
  late String _keyWord = widget.keyWord ?? '';
  final List<ExtensionListItem> _data = [];
  int _page = 1;
  bool _isLoading = true;
  final EasyRefreshController _easyRefreshController = EasyRefreshController();
  Map<String, ExtensionFilter>? _filters;

  // 初始化一开始选择的选项
  Map<String, List<String>> _selectedFilters = {};

  late final _textEditingController = TextEditingController(text: _keyWord);
  late ExtensionHelper extensionHelper = ExtensionHelper(_extension);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _initFilters();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _initFilters() async {
    var f = await extensionHelper.createFilter();
    if (f == null) return;
    _filters = f;
    _filters?.forEach((key, value) {
      _selectedFilters[key] = [value.defaultOption];
    });
    setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() {
      _page = 1;
      _data.clear();
    });
    await _onLoad();
  }

  Future<void> _onLoad() async {
    try {
      _isLoading = true;
      setState(() {});
      late List<ExtensionListItem> data;
      if (_keyWord.isEmpty && _filters == null) {
        data = await extensionHelper.latest(_page);
      } else {
        data = await extensionHelper.search(_keyWord, _page,
            filter: _selectedFilters);
      }
      if (data.isEmpty && mounted) {
        showPlatformSnackbar(
          context: context,
          content: "common.no-more-data".i18n,
          severity: fluent.InfoBarSeverity.warning,
        );
      }
      _data.addAll(data);
      _page++;
    } catch (e) {
      // ignore: use_build_context_synchronously
      showPlatformSnackbar(
        context: context,
        content: e.toString(),
        severity: fluent.InfoBarSeverity.error,
      );
      rethrow;
    } finally {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  _onSearch(String keyWord) {
    _keyWord = keyWord;
    if (Platform.isAndroid || Platform.isIOS) {
      _easyRefreshController.callRefresh();
    } else {
      _onRefresh();
    }
  }

  _onFilter(BuildContext context) {
    final filterWidget = _ExtensionFilterWidget(
      filters: _filters!,
      selectedFilters: _selectedFilters,
      onSelectFilter: (selectedFilters, filters) {
        _selectedFilters = selectedFilters;
        _filters = filters;
      },
      extensionHelper: extensionHelper,
    );

    if (Platform.isAndroid || Platform.isIOS) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("common.cancel".i18n),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      Get.back();
                      _easyRefreshController.callRefresh();
                    },
                    child: Text("common.confirm".i18n),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
              child: filterWidget,
            ))
          ],
        ),
      );
      return;
    }

    fluent.showDialog(
      context: context,
      builder: (context) {
        return fluent.ContentDialog(
          title: Text('search.filter'.i18n),
          content: filterWidget,
          actions: [
            fluent.Button(
              child: Text('common.cancel'.i18n),
              onPressed: () {
                router.pop();
              },
            ),
            fluent.FilledButton(
              child: Text('common.confirm'.i18n),
              onPressed: () {
                router.pop();
                _onRefresh();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        title: _extension.name,
        textEditingController: _textEditingController,
        onChanged: (value) {
          if (value.isEmpty) {
            _onSearch(value);
          }
        },
        onSubmitted: _onSearch,
        actions: [
          if (_filters != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_rounded),
              onPressed: () => _onFilter(context),
            ),
        ],
      ),
      body: InfiniteScroller(
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        easyRefreshController: _easyRefreshController,
        child: LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth ~/ 120,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final item = _data[index];
              return ExtensionItemCard(
                title: item.title,
                url: item.url,
                package: widget.package,
                cover: item.cover,
                update: item.update,
                headers: item.headers,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final suffix = Row(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 2.0),
        child: fluent.IconButton(
          icon: const Icon(fluent.FluentIcons.chrome_close, size: 9.0),
          onPressed: () {
            _textEditingController.clear();
            _onSearch("");
          },
        ),
      ),
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const SizedBox(
            height: 4,
            width: double.infinity,
            child: fluent.ProgressBar(),
          )
        else
          const SizedBox(height: 4),
        fluent.Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _extension.name,
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
              ),
              const Spacer(),
              if (_filters != null)
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.filter),
                  onPressed: () => _onFilter(context),
                ),
              const SizedBox(width: 8),
              SizedBox(
                width: 300,
                child: fluent.TextBox(
                  controller: TextEditingController(
                    text: _keyWord,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _onSearch(value);
                    }
                  },
                  suffix: suffix,
                  suffixMode: fluent.OverlayVisibilityMode.editing,
                  onSubmitted: _onSearch,
                  placeholder: 'search.hint-text'.i18n,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: InfiniteScroller(
            onRefresh: _onRefresh,
            onLoad: _onLoad,
            child: LayoutBuilder(
              builder: ((context, constraints) => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth ~/ 160,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      return ExtensionItemCard(
                        title: item.title,
                        url: item.url,
                        package: widget.package,
                        cover: item.cover,
                        update: item.update,
                        headers: item.headers,
                      );
                    },
                  )),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final extension = ExtensionUtils.extensions[widget.package];
    final extensionMissing = Text(
      FlutterI18n.translate(
        context,
        'common-extension-missing',
        translationParams: {'package': widget.package},
      ),
    );
    if (extension == null) {
      return PlatformWidget(
        mobileWidget: Scaffold(
          body: extensionMissing,
        ),
        desktopWidget: Center(
          child: extensionMissing,
        ),
      );
    }
    _extension = extension;
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}

class _ExtensionFilterWidget extends StatefulWidget {
  const _ExtensionFilterWidget({
    required this.selectedFilters,
    required this.onSelectFilter,
    required this.filters,
    required this.extensionHelper,
  });

  final Map<String, ExtensionFilter> filters;
  final Map<String, List<String>> selectedFilters;
  final Function(
    Map<String, List<String>> selectedFilters,
    Map<String, ExtensionFilter> filters,
  ) onSelectFilter;
  final ExtensionHelper? extensionHelper;

  @override
  State<_ExtensionFilterWidget> createState() => _ExtensionFilterWidgetState();
}

class _ExtensionFilterWidgetState extends State<_ExtensionFilterWidget> {
  late Map<String, ExtensionFilter> _filters = widget.filters;

  // 初始化一开始选择的选项
  late Map<String, List<String>> _selectedFilters = widget.selectedFilters;

  _onSelectFilter(key, value) async {
    final selectedFilters = Map<String, List<String>>.from(_selectedFilters);
    // 如果存在就删除，不存在就添加
    if (selectedFilters[key]!.contains(value)) {
      if (selectedFilters[key]!.length > _filters[key]!.min) {
        selectedFilters[key]!.remove(value);
      }
    } else {
      if (selectedFilters[key]!.length >= _filters[key]!.max) {
        selectedFilters[key]!.removeAt(0);
      }
      selectedFilters[key]!.add(value);
    }
    var f = await widget.extensionHelper?.createFilter(filter: selectedFilters);
    if (f == null) return;
    // 再请求一次 _filters
    final filters = Map<String, ExtensionFilter>.from(
      f,
    );

    // 剔除 _filters 中不能存在的选项
    selectedFilters.forEach((key, value) {
      if (!filters.containsKey(key)) {
        selectedFilters.remove(key);
      }
    });

    setState(() {
      _selectedFilters = selectedFilters;
      _filters = filters;
    });
    widget.onSelectFilter(_selectedFilters, _filters);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final filter in _filters.entries) ...[
            Text(
              filter.value.title,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in filter.value.options.entries) ...[
                  PlatformToggleButton(
                    onChanged: (value) async {
                      await _onSelectFilter(
                        filter.key,
                        entry.key,
                      );
                      setState(() {});
                    },
                    checked: widget.selectedFilters[filter.key]!.contains(
                      entry.key,
                    ),
                    text: entry.value,
                  ),
                ]
              ],
            ),
            const SizedBox(height: 16)
          ],
        ],
      ),
    );
  }
}
