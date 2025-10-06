import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';

/// Hierarchy:
/// - [DeclarativeNavigatable]
///   - [PageDeclarativeNavigatable]
///   - [ElementDeclarativeNavigatable]
///     - [StatelessNavigator]
///     - [StatefulNavigator]
sealed class DeclarativeNavigatable {}

abstract class PageDeclarativeNavigatable implements DeclarativeNavigatable {
  DeclarativePage build();
}

sealed class ElementDeclarativeNavigatable implements DeclarativeNavigatable {
  NavigatorElement createElement();
}

abstract class StatelessNavigator implements ElementDeclarativeNavigatable {
  StatelessNavigator({this.key});

  final String? key;

  @override
  @protected
  StatelessNavigatorElement createElement() => StatelessNavigatorElement(this);

  @protected
  List<DeclarativeNavigatable> build();
}

abstract class StatefulNavigator implements ElementDeclarativeNavigatable {
  StatefulNavigator({this.key});

  final String? key;

  @override
  @protected
  StatefulNavigatorElement createElement() => StatefulNavigatorElement(this);

  @protected
  DeclarativeNavigatorState createState();
}

abstract class DeclarativeNavigatorState<T extends StatefulNavigator> {
  late T navigator;

  late StatefulNavigatorElement element;

  @protected
  void setState(void Function() fn) {
    fn();

    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    element.notifyListeners();
  }

  // context AKA element needed (for refresh?)

  @protected
  @mustCallSuper
  void initState() {}

  @mustCallSuper
  @protected
  void didUpdateNavigator(covariant T oldNavigator) {}

  @protected
  List<DeclarativeNavigatable> build();

  @mustCallSuper
  void dispose() {}
}

abstract class NavigatorElement<T> extends ChangeNotifier {
  void update(T navigator);

  List<DeclarativeNavigatable> build();

  @override
  void dispose();
}

class StatefulNavigatorElement<T extends StatefulNavigator>
    extends ChangeNotifier implements NavigatorElement<T> {
  StatefulNavigatorElement(T statefulNavigator);

  // DeclarativeNavigatorState<StatefulNavigator> get state => _state!;
  // DeclarativeNavigatorState<StatefulNavigator> get state => _state!;
  DeclarativeNavigatorState<StatefulNavigator>? state;

  void init() {}

  // TODO: Diff in old element

  @override
  void update(T newNavigator) {
    final oldNavigator = state!.navigator as T;

    state!.navigator = newNavigator;

    state!.didUpdateNavigator(oldNavigator);
  }

  @override
  List<DeclarativeNavigatable> build() {
    return state!.build();
  }

  @mustCallSuper
  @override
  void dispose() {
    state!.dispose();

    super.dispose();
  }
}

class StatelessNavigatorElement<T extends StatelessNavigator>
    implements NavigatorElement<T> {
  StatelessNavigatorElement(this._navigator);

  T _navigator;

  @override
  void update(T navigator) {
    _navigator = navigator;
  }

  @override
  List<DeclarativeNavigatable> build() {
    return _navigator.build();
  }

  @override
  void dispose() {}

  // Dummy change notifier implementation. Maybe we could also just drop this.
  @override
  void addListener(VoidCallback listener) {}

  @override
  bool get hasListeners => false;

  @override
  void notifyListeners() {}

  @override
  void removeListener(VoidCallback listener) {}

  // No, even if the navigator is the same, we still need to call `build` for re-rendering
  //   @override
  // int get hashCode => navigator.hashCode;

  // @override
  // bool operator ==(Object other) {
  //   return (other is ChildNavigatorDescription &&
  //       other.navigator == navigator);
}
