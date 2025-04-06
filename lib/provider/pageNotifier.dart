import 'package:flutter/cupertino.dart';

class PageNotifier extends ChangeNotifier {
  double _page = 0.0;

  double get page => _page;

  void listener(double value) {
    if (_page != value) {
      _page = value;
      notifyListeners();
    }
  }
}