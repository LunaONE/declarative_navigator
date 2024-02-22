import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/foundation.dart';

abstract class MappedNavigator<T> extends SingleChildNavigator {
  @protected
  ValueListenable<T> get source;

  late final VoidCallback removeSourceListener;

  late NavigatorDescription _desc;

  MappedNavigator() {
    // TODO(tp): How to handle hot-reload? Special listener, or rather re-evaluate `map` on global rebuilds?
    void handleUpdate() {
      _desc = map(source.value);

      notifyListeners();
    }

    source.addListener(handleUpdate);
    handleUpdate();
    removeSourceListener = () => source.removeListener(handleUpdate);
  }

  NavigatorDescription map(T value);

  @override
  NavigatorDescription describe() {
    return _desc;
  }

  @override
  void dispose() {
    removeSourceListener();

    super.dispose();
  }
}
