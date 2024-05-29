import 'package:flutter/material.dart';

class TopNavProvider with ChangeNotifier {
  late TabController _tabController;

  void initTabController(TickerProvider vsync, int length) {
    _tabController = TabController(vsync: vsync, length: length);
  }

  TabController get tabController => _tabController;

  int get currentIndex => _tabController.index;

  set changeIndex(int index) {
    _tabController.index = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
