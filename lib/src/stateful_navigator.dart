import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/foundation.dart';

abstract class StatefulNavigator extends SingleChildNavigator {
  @protected
  void setState(VoidCallback fn) {
    fn();

    notifyListeners();
  }
}
