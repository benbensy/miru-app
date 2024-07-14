import 'package:miru_app/data/services/extension_interface.dart';
import 'package:miru_app/data/services/extension_interface_wrapper.dart';
import 'package:miru_app/data/services/runtime_helper.dart';
import 'package:miru_app/models/extension.dart';

class ExtensionHelper extends ExtensionInterface {
  ExtensionHelper(this.extension);

  Extension extension;

  ExtensionInterfaceWrapper? wrapper;

  Future<void> _initWrapperRuntime() async {
    if (wrapper == null) {
      var className = RuntimeHelper.instance.handleClassName(extension);
      var runtime = await RuntimeHelper.instance.getRuntime(extension);
      wrapper = ExtensionInterfaceWrapper(runtime, extension, className);
    }
  }

  @override
  Future<String> checkUpdate(url) async {
    await _initWrapperRuntime();
    return wrapper!.checkUpdate(url);
  }

  @override
  Future<Map<String, ExtensionFilter>?> createFilter(
      {Map<String, List<String>>? filter}) async {
    await _initWrapperRuntime();
    return wrapper!.createFilter(filter: filter);
  }

  @override
  Future<ExtensionDetail> detail(String url) async {
    await _initWrapperRuntime();
    return wrapper!.detail(url);
  }

  @override
  Future<List<ExtensionListItem>> latest(int page) async {
    await _initWrapperRuntime();
    return wrapper!.latest(page);
  }

  @override
  Future<List<ExtensionListItem>> search(String kw, int page,
      {Map<String, List<String>>? filter}) async {
    await _initWrapperRuntime();
    return wrapper!.search(kw, page, filter: filter);
  }

  @override
  Future<Object?> watch(String url) async {
    await _initWrapperRuntime();
    return wrapper!.watch(url);
  }

  @override
  Future<List<String>?> tags(String url) async {
    await _initWrapperRuntime();
    return wrapper!.tags(url);
  }
}
