import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/index.dart';
import 'package:miru_app/data/services/database_service.dart';

class HomePageController extends GetxController {
  final RxList<History> resents = <History>[].obs;
  final RxMap<ExtensionType, List<Favorite>> favorites =
      <ExtensionType, List<Favorite>>{}.obs;

  final ScrollController pageController = ScrollController(
    //initialPage: 0,
   // viewportFraction: 0.5,
  );
  double page = 0.0;

  @override
  void onInit() {
    onRefresh();
    super.onInit();
    pageController.addListener(_onScroll);
  }

  @override
  void onClose() {
    pageController.removeListener(_onScroll);
    pageController.dispose();
    super.onClose();
  }

  void _onScroll() {
    page = pageController.offset;
    update();
  }

  refreshHistory() async {
    resents.clear();
    resents.addAll(
      await DatabaseService.getHistorysByType(),
    );
  }

  onRefresh() async {
    favorites.clear();
    await refreshHistory();
    favorites.addAll({
      ExtensionType.bangumi: await DatabaseService.getFavoritesByType(
        type: ExtensionType.bangumi,
        limit: 20,
      ),
      ExtensionType.manga: await DatabaseService.getFavoritesByType(
        type: ExtensionType.manga,
        limit: 20,
      ),
      ExtensionType.fikushon: await DatabaseService.getFavoritesByType(
        type: ExtensionType.fikushon,
        limit: 20,
      ),
    });
  }
}
